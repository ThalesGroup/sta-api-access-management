package com.thalesgroup.apiprotection.model

import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.net.Uri
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.liveData
import androidx.lifecycle.viewModelScope
import androidx.preference.PreferenceManager
import com.auth0.android.jwt.JWT
import com.thalesgroup.apiprotection.config.Config
import com.thalesgroup.apiprotection.oauth.FreshTokenResult
import com.thalesgroup.apiprotection.restapi.Resource
import com.thalesgroup.apiprotection.restapi.RetailRestApi
import com.thalesgroup.apiprotection.restapi.Shop
import com.thalesgroup.apiprotection.restapi.Warehouse
import com.thalesgroup.apiprotection.ui.ConfigFragment
import com.thalesgroup.apiprotection.ui.MainActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import net.openid.appauth.*
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okio.Okio
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.net.HttpURLConnection
import java.net.URL
import java.nio.charset.Charset
import java.util.concurrent.TimeUnit
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine


/**
 * View model to the retail repository and UI.
 */
class RetailViewModel: ViewModel() {

    lateinit var config: Config
    var clientAuth: ClientAuthentication? = null

    /**
     * This auth state captures the login flow authorization.
     */
    var authState: AuthState? = null

    /**
     * This auth state captures the client credential authorization
     */
    var publicAuthState: AuthState? = null
    lateinit var authService: AuthorizationService
    private val retailRepository = RetailRepository()
    private var userInfo: UserInfo? = null
    lateinit var resources: Resources
    val liveUserInfo: MutableLiveData<UserInfo> by lazy {
        MutableLiveData<UserInfo>()
    }


    fun initialize(context: Context) {
        resources = context.resources
        if (!this::authService.isInitialized) {
            authService = AuthorizationService(context)
        }
        userInfo = UserInfo("","")

        liveUserInfo.postValue(userInfo)
    }

    fun resetAuthState() {
        clientAuth = null
        authState = null
        publicAuthState = null
        userInfo = UserInfo("","")
        liveUserInfo.postValue(userInfo)
    }

    private fun beginPublicAuth(callback: Continuation<Exception?>) {
        if (!config.publicClientWellknown.startsWith("https", true)) {
            callback.resume(Exception("Public wellknown discovery url: ${config.publicClientWellknown} is invalid"))
            return
        }
        AuthorizationServiceConfiguration.fetchFromIssuer(
                Uri.parse(config.publicClientWellknown),
                AuthorizationServiceConfiguration.RetrieveConfigurationCallback { serviceConfiguration, ex ->
                    if (ex != null || serviceConfiguration == null) {
                        Log.e("RetailViewModel", "failed to fetch configuration")
                        callback.resume(ex)
                        return@RetrieveConfigurationCallback
                    }
                    val publicClientAuth = ClientSecretBasic(config.publicClientSecret)
                    val builder = TokenRequest.Builder(serviceConfiguration, config.publicClientId)
                    builder.setScope("openid email profile")
                    builder.setGrantType(TokenRequest.GRANT_TYPE_CLIENT_CREDENTIALS)
                    authService.performTokenRequest(
                            builder.build(),
                            publicClientAuth
                    ) { tokenResponse: TokenResponse?, authorizationException: AuthorizationException? ->
                        if (authorizationException != null) {
                            callback.resume(authorizationException)
                            return@performTokenRequest
                        }
                        publicAuthState = AuthState(serviceConfiguration)
                        publicAuthState!!.update(tokenResponse, authorizationException)

                        userInfo = UserInfo("","")
                        liveUserInfo.postValue(userInfo)
                        callback.resume(null)
                    }
                })
    }


    fun beginEmployeeManagerAuth(context: Context, callback: (authIntent: Intent) -> Unit) {
        AuthorizationServiceConfiguration.fetchFromIssuer(
                Uri.parse(config.retailClientWellknown),
                AuthorizationServiceConfiguration.RetrieveConfigurationCallback { serviceConfiguration, ex ->
                    if (ex != null || serviceConfiguration == null) {
                        Log.e(MainActivity.TAG, "failed to fetch configuration")
                        return@RetrieveConfigurationCallback
                    }
                    val authRequestBuilder = AuthorizationRequest.Builder(
                            serviceConfiguration,
                            config.retailClientId,
                            ResponseTypeValues.CODE,
//                        Uri.parse("com.spe-demo.apps:/oauth2redirect")
                            Uri.parse("com.spe-demo.apps:/oauth2redirect")
                    ) // the redirect URI to which the auth response is sent
                    authRequestBuilder.setScope("openid email profile")
                    val loginHint = PreferenceManager.getDefaultSharedPreferences(context)
                            .getString(ConfigFragment.PREF_LOGIN, "")
                    if (loginHint != "") {
                        authRequestBuilder.setLoginHint(loginHint)
                    }
                    val authRequest = authRequestBuilder.build()
                    val authIntent = authService.getAuthorizationRequestIntent(authRequest)
                    authState = AuthState(serviceConfiguration)
                    callback.invoke(authIntent)
                })
    }


    fun fetchUserInfo(accessToken: String, errorCallback: (exception: Exception?) -> Unit = {}) {
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val userInfoUri = authState?.authorizationServiceConfiguration!!.discoveryDoc!!.userinfoEndpoint
                val userInfoEndpoint = URL(userInfoUri.toString())
                val conn: HttpURLConnection = userInfoEndpoint.openConnection() as HttpURLConnection
                conn.setRequestProperty("Authorization", "Bearer $accessToken")
                conn.instanceFollowRedirects = false
                val response: String = Okio.buffer(Okio.source(conn.inputStream)).readString(Charset.forName("UTF-8"))
                val jwt = JWT(response)
                val email = jwt.getClaim("email").asString()!!
                val name = jwt.getClaim("name").asString()!!
                userInfo = UserInfo(email, name)
                liveUserInfo.postValue(userInfo)
            } catch (ex: Exception) {
                errorCallback.invoke(ex)
            }
        }
    }


    fun updateConfig(config: Config) {
        this.config = config
        resetAuthState()
        retailRepository.webservice = createApi()
    }

    class AuthorizationInterceptor : Interceptor {
        override fun intercept(chain: Interceptor.Chain): okhttp3.Response {
            // Doing nothing now, but useful to know that this interceptor can be used
            // if necessary to modify a response before feeding it to the UI
            //            if (mainResponse.code() == 401 || mainResponse.code() == 403) {
//            }
            return chain.proceed(chain.request())
        }
    }


    private fun provideOkHttpClient(): OkHttpClient {
        val okhttpClientBuilder = OkHttpClient.Builder()
        okhttpClientBuilder.connectTimeout(30, TimeUnit.SECONDS)
        okhttpClientBuilder.readTimeout(30, TimeUnit.SECONDS)
        okhttpClientBuilder.writeTimeout(30, TimeUnit.SECONDS)
        okhttpClientBuilder.addInterceptor(AuthorizationInterceptor())
        return okhttpClientBuilder.build()
    }

    private fun createApi(): RetailRestApi? {
        val retrofit = Retrofit.Builder()
                .client(provideOkHttpClient())
            .addConverterFactory(GsonConverterFactory.create())
        if (config.apiUrl.startsWith("https", true)) {
            retrofit.baseUrl(config.apiUrl)
        } else {
            return null
        }
        return retrofit.build().create(RetailRestApi::class.java)
    }

    private fun fetchFreshTokens(callback: Continuation<FreshTokenResult>) {
        clientAuth?.let {
            try {
                authState?.performActionWithFreshTokens(authService, it) { accessToken, idToken, ex ->
                    callback.resume(FreshTokenResult(accessToken, idToken, ex))
                }
            } catch (exception: Exception) {
                callback.resume(FreshTokenResult(null, null, exception))
            }
        }
    }

    private suspend fun ensureFreshTokens(): FreshTokenResult {
        if (authState != null) {
            // Retail auth is provided and saved, continue refreshing this
            return suspendCoroutine { fetchFreshTokens(it) }
        } else if (publicAuthState != null) {
             if (publicAuthState!!.needsTokenRefresh) {
                 // Public auth has been used once but has expired, repeat the public auth
                 val exception = suspendCoroutine<Exception?> { beginPublicAuth(it) }
                 if (exception != null) {
                     return FreshTokenResult(null, null, exception)
                 }
                 return FreshTokenResult(
                         publicAuthState!!.accessToken,
                         publicAuthState!!.idToken,
                         null
                 )
             } else {
                 // Public auth has been used once, we can keep using the access token so long as it is fresh
                 return FreshTokenResult(
                         publicAuthState!!.accessToken,
                         publicAuthState!!.idToken,
                         null
                 )
             }
        } else {
            // Public auth has never been used, get public auth
            val exception = suspendCoroutine<Exception?> { beginPublicAuth(it) }
            if (exception != null) {
                return FreshTokenResult(null, null, exception)
            }
            return FreshTokenResult(publicAuthState!!.accessToken, publicAuthState!!.idToken, null)
        }
    }

    fun fetchShops() = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            emit(Resource.success(data = retailRepository.getShops(freshTokenResult.accessToken!!)))
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }

    }

    fun fetchShopsWithInfo() = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            val detailedShops: MutableList<Shop>? = retailRepository.getShops(freshTokenResult.accessToken!!)
            detailedShops?.forEach {
                val shopInfo = retailRepository.getShopInfo(freshTokenResult.accessToken, it.id) ?: return@forEach
                it.description = shopInfo.description
            }
            emit(Resource.success(data = detailedShops))
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun fetchWarehousesWithInfo() = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            val detailedWarehouses: MutableList<Warehouse>? = retailRepository.getWarehouses(
                    freshTokenResult.accessToken!!
            )
            detailedWarehouses?.forEach {
                val warehouseInfo = retailRepository.getWarehouseInfo(
                        freshTokenResult.accessToken,
                        it.id
                ) ?: return@forEach
                it.description = warehouseInfo.description
            }
            emit(Resource.success(data = detailedWarehouses))

        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun fetchWarehouses() = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            emit(Resource.success(data = retailRepository.getWarehouses(freshTokenResult.accessToken!!)))
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun fetchShopInfo(shopId: String) = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            emit(
                    Resource.success(
                            data = retailRepository.getShopInfo(
                                    freshTokenResult.accessToken!!,
                                    shopId
                            )
                    )
            )
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun fetchWarehouseInfo(warehouseId: String) = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            emit(
                    Resource.success(
                            data = retailRepository.getWarehouseInfo(
                                    freshTokenResult.accessToken!!,
                                    warehouseId
                            )
                    )
            )
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun fetchShopStock(retailId: String) = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            emit(
                    Resource.success(
                            data = retailRepository.getShopStock(
                                    freshTokenResult.accessToken!!,
                                    retailId
                            )
                    )
            )
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun fetchWarehouseStock(retailId: String) = liveData(Dispatchers.IO) {
        emit(Resource.loading(data = null))
        val freshTokenResult = ensureFreshTokens()
        if (!freshTokenResult.isFresh()) {
            emit(
                    Resource.error(
                            data = null,
                            message = freshTokenResult.ex?.message ?: "Error Occurred!",
                            exception = freshTokenResult.ex
                    )
            )
            return@liveData
        }
        try {
            emit(
                    Resource.success(
                            data = retailRepository.getWarehouseStock(
                                    freshTokenResult.accessToken!!,
                                    retailId
                            )
                    )
            )
        } catch (exception: Exception) {
            emit(
                    Resource.error(
                            data = null,
                            message = exception.message ?: "Error Occurred!",
                            exception = exception
                    )
            )
        }
    }

    fun resetServer(callback: (success: Boolean) -> Unit = {}) {
        viewModelScope.launch {
            val freshTokenResult = ensureFreshTokens()
            if (!freshTokenResult.isFresh()) {
                callback.invoke(false)
            }
            try {
                retailRepository.reset(freshTokenResult.accessToken!!)
            } catch (exception: Exception) {
                callback.invoke(false)
            }
            callback.invoke(true)
        }
    }

    fun moveStock(
            stockId: String,
            count: Int,
            warehouseId: String,
            shopId: String,
            listener: (ex: Exception?) -> Unit = {}
    ) {
        viewModelScope.launch {

            val freshTokenResult = ensureFreshTokens()
            if (!freshTokenResult.isFresh()) {
                listener.invoke(Exception("OAuth credentials have expired"))
                return@launch
            }
            try {
                retailRepository.moveStock(
                        freshTokenResult.accessToken!!,
                        stockId,
                        count,
                        warehouseId,
                        shopId
                )
            } catch (exception: Exception) {
                withContext(Dispatchers.Main) {
                    listener.invoke(exception)
                }
                return@launch
            }
            withContext(Dispatchers.Main) {
                listener.invoke(null)
            }
        }
    }

}