package com.thalesgroup.apiprotection.ui

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import androidx.preference.PreferenceManager
import com.google.gson.Gson
import com.thalesgroup.apiprotection.R
import com.thalesgroup.apiprotection.config.Config
import com.thalesgroup.apiprotection.databinding.ActivityMainBinding
import com.thalesgroup.apiprotection.databinding.NavHeaderMainBinding
import com.thalesgroup.apiprotection.model.RetailViewModel
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_HAS_INITIALIZED
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_PUBLIC_CLIENT_ID
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_PUBLIC_CLIENT_SECRET
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_PUBLIC_WELLKNOWN
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_RETAIL_CLIENT_ID
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_RETAIL_CLIENT_SECRET
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_RETAIL_WELLKNOWN
import com.thalesgroup.apiprotection.ui.ConfigFragment.Companion.PREF_SERVER_URL
import net.openid.appauth.AuthorizationException
import net.openid.appauth.AuthorizationResponse
import net.openid.appauth.ClientSecretBasic
import org.json.JSONObject
import retrofit2.HttpException
import java.io.*


class MainActivity : AppCompatActivity() {
    companion object {
        const val TAG = "ApiProtDemo"
        const val RC_AUTH = 100
    }

    private lateinit var appBarConfiguration: AppBarConfiguration
    private lateinit var binding: ActivityMainBinding
    private lateinit var headerBinding: NavHeaderMainBinding

    private val viewModel by viewModels<RetailViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
        binding = ActivityMainBinding.inflate(layoutInflater)
        headerBinding = NavHeaderMainBinding.bind(binding.navView.getHeaderView(0))

        setContentView(binding.root)
        setSupportActionBar(binding.appBar.toolbar)

        val navController = findNavController(R.id.nav_host_fragment)
        appBarConfiguration = AppBarConfiguration(
            setOf(
                R.id.nav_map, R.id.nav_configuration, R.id.nav_login
            ), binding.drawerLayout
        )
        setupActionBarWithNavController(navController, appBarConfiguration)

        binding.navView.setupWithNavController(navController)
        binding.navView.menu.getItem(1).setOnMenuItemClickListener {
            showLongLoad()
            viewModel.beginEmployeeManagerAuth(this) {
                hideLoadingBar()
                startActivityForResult(it, RC_AUTH)
            }
            false
        }
        try {
            setDefaultPreferenceValues()
        } catch (exception: Exception) {
            Toast.makeText(this, getString(R.string.launch_error) + exception.message, Toast.LENGTH_LONG).show()
        }
        if (savedInstanceState == null) {
            onNewIntent(intent)
        }
        viewModel.initialize(this)
        viewModel.liveUserInfo.observe(this) {
            it?.apply {
                if (it.name.isBlank() || it.email.isBlank()) {
                    headerBinding.drawerFieldTitle.setText(R.string.display_no_user)
                    if (viewModel.publicAuthState == null) {
                        headerBinding.drawerFieldSubtitle.setText(R.string.display_no_credentials)
                    } else {
                        headerBinding.drawerFieldSubtitle.setText(R.string.display_public_credentials)
                    }
                } else {
                    headerBinding.drawerFieldTitle.text = it.name
                    headerBinding.drawerFieldSubtitle.text = it.email
                }
            }
        }
    }

    fun showLongLoad() {
        binding.appBar.loadingOverlay.visibility = View.VISIBLE
    }

    fun showShortLoad() {
        // Do nothing for now
        binding.appBar.shortLoadingBar.visibility = View.VISIBLE
    }

    fun hideLoadingBar() {
        binding.appBar.loadingOverlay.visibility = View.GONE
        binding.appBar.shortLoadingBar.visibility = View.GONE
    }

    private fun setDefaultPreferenceValues() {
        val preferences = PreferenceManager.getDefaultSharedPreferences(this)
        val config = if (preferences.getBoolean(PREF_HAS_INITIALIZED, false)) {
            loadConfig()
        } else {
            // Load in an empty config. The user must load a config in externally in order to use the
            // app, or you must modify this config to provide a default
            val config = Config(
                "",
                "",
                "",
                "",
                "",
                "",
                ""
            )
            saveConfig(config)
            config
        }
        if (config.apiUrl.isBlank()) {
            Toast.makeText(this, "Config is blank, please load a config.json file", Toast.LENGTH_LONG).show()
        }
        viewModel.updateConfig(config)
    }

    private fun saveConfig(config: Config) {
        val preferences = PreferenceManager.getDefaultSharedPreferences(this)
        preferences.edit()
            .putString(PREF_SERVER_URL, config.apiUrl)
            .putString(PREF_PUBLIC_CLIENT_ID, config.publicClientId)
            .putString(PREF_PUBLIC_CLIENT_SECRET, config.publicClientSecret)
            .putString(PREF_PUBLIC_WELLKNOWN, config.publicClientWellknown)
            .putString(PREF_RETAIL_CLIENT_ID, config.retailClientId)
            .putString(PREF_RETAIL_CLIENT_SECRET, config.retailClientSecret)
            .putString(PREF_RETAIL_WELLKNOWN, config.retailClientWellknown)
            .putBoolean(PREF_HAS_INITIALIZED, true)
            .apply()
    }

    private fun loadConfig(): Config {
        val preferences = PreferenceManager.getDefaultSharedPreferences(this)
        val apiUrl = preferences.getString(PREF_SERVER_URL, "") ?: ""
        val publicClientId = preferences.getString(PREF_PUBLIC_CLIENT_ID, "") ?: ""
        val publicClientSecret = preferences.getString(PREF_PUBLIC_CLIENT_SECRET, "") ?: ""
        val publicClientWellknown = preferences.getString(PREF_PUBLIC_WELLKNOWN, "") ?: ""
        val retailClientId = preferences.getString(PREF_RETAIL_CLIENT_ID, "") ?: ""
        val retailClientSecret = preferences.getString(PREF_RETAIL_CLIENT_SECRET, "") ?: ""
        val retailClientWellknown = preferences.getString(PREF_RETAIL_WELLKNOWN, "") ?: ""
        return Config(
            apiUrl,
            publicClientId,
            publicClientSecret,
            publicClientWellknown,
            retailClientId,
            retailClientSecret,
            retailClientWellknown
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action.equals(Intent.ACTION_VIEW) && intent.type == "application/json") {
            // This intent is received when the app gets a json file shared with it
            val config = readConfigFromShare(intent.data) ?: return
            try {
                viewModel.updateConfig(config)
            } catch (exception: IllegalArgumentException) {
                if (exception.toString().contains("baseUrl must end in /")) {
                    config.apiUrl = "${config.apiUrl}/"
                    viewModel.updateConfig(config)
                }
                else {
                    Toast.makeText(
                        this,
                        getString(R.string.config_read_failure) + exception.message,
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
            saveConfig(config)
            Toast.makeText(this, R.string.config_read_successful, Toast.LENGTH_LONG).show()
        }
    }

    private fun readConfigFromShare(data: Uri?): Config? {
        if (data == null) {
            return null
        }
        try {
            val cr = applicationContext.contentResolver
            val inputStream: InputStream? = cr.openInputStream(data)
            val gson = Gson()
            val reader = BufferedReader(InputStreamReader(inputStream))
            return gson.fromJson(reader, Config::class.java)
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
            Toast.makeText(this, R.string.file_read_not_found, Toast.LENGTH_LONG).show()
        } catch (e: IOException) {
            e.printStackTrace()
            Toast.makeText(this, R.string.file_read_failure, Toast.LENGTH_LONG).show()
        }
        return null
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment)
        return navController.navigateUp(appBarConfiguration) || super.onSupportNavigateUp()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        binding.root.closeDrawers()
        if (requestCode == RC_AUTH) {
            val resp = AuthorizationResponse.fromIntent(data!!)
            val ex = AuthorizationException.fromIntent(data)
            if (resp == null) {
                // Reset the auth state so the API can go back to using the public login
                handleError(ex)
                viewModel.resetAuthState()
                return
            }
            viewModel.authState?.update(resp, ex)
            viewModel.clientAuth = ClientSecretBasic(viewModel.config.retailClientSecret)
            viewModel.authService.performTokenRequest(
                resp.createTokenExchangeRequest(),
                viewModel.clientAuth!!
            ) { tokenResponse, exception ->
                if (tokenResponse != null) {
                    viewModel.authState?.update(tokenResponse, exception)
                    viewModel.fetchUserInfo(tokenResponse.accessToken!!) {
                        handleError(it)
                    }
                }
            }
        }
    }

    /**
     * Makes a best effort to read a more helpful error message from the server response.
     */
    private fun getErrorMessage(exception: Exception?): String {
        if (exception == null) {
            return ""
        }
        var errorMessage : String? = if (exception is HttpException) {
            // Only read this once! The buffer gets cleared after you read this
            exception.response()?.errorBody()?.string()
        } else {
            exception.message
        }
        if (errorMessage.isNullOrBlank()) {
            //
            errorMessage = exception.message
        }

        val parsedMessage = try {
            val jsonObject = JSONObject(errorMessage!!)
            // Server sends lower case sometimes, upper case other times
            jsonObject.getString("message")
        } catch (ex: Exception) {
            try {
                val jsonObject = JSONObject(errorMessage!!)
                // Here's the upper case
                jsonObject.getString("Message")
            } catch (ex: Exception) {
                errorMessage
            }
        }
        return parsedMessage ?: "Unknown error"
    }

    fun handleError(exception: Exception?) {
        if (exception == null) {
            return // no error sent
        }
        Log.e(TAG, "Exception", exception)
        val errorMessage = getErrorMessage(exception)
        Toast.makeText(this, "Error: $errorMessage", Toast.LENGTH_LONG).show()
    }
}