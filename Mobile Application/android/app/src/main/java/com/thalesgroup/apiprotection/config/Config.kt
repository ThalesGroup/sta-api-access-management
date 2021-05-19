package com.thalesgroup.apiprotection.config

/**
 * Config class that is used when reading in a json config file. Provides all the information
 * necessary to configure the app to work with a different server instance.
 */
data class Config(
    /**
     * The URL of the protected or backend API
     */
    var apiUrl: String,
    /**
     * The client id for client credential flow
     */
    val publicClientId: String,
    /**
     * The client secret for client credential flow
     */
    val publicClientSecret: String,
    /**
     * The well known discovery url for client credential flow
     */
    var publicClientWellknown: String,
    /**
     * The client id for authorized oauth flow
     */
    val retailClientId: String,
    /**
     * The client secret for authorized oauth flow
     */
    val retailClientSecret: String,
    /**
     * The well known discovery url for authorized oauth flow
     */
    var retailClientWellknown: String
) {
    init {
        removeOpenIDSuffix()
    }

    fun removeOpenIDSuffix() {
        publicClientWellknown =
            publicClientWellknown.removeSuffix(".well-known/openid-configuration")
        retailClientWellknown =
            retailClientWellknown.removeSuffix(".well-known/openid-configuration")
        publicClientWellknown =
            publicClientWellknown.removeSuffix(".well-known/openid-configuration/")
        retailClientWellknown =
            retailClientWellknown.removeSuffix(".well-known/openid-configuration/")
    }
}