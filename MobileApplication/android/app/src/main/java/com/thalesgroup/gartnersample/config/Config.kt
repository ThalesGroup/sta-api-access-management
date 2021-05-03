package com.thalesgroup.gartnersample.config

data class Config(var apiUrl: String,
                  val publicClientId: String,
                  val publicClientSecret: String,
                  var publicClientWellknown: String,
                  val retailClientId: String,
                  val retailClientSecret: String,
                  var retailClientWellknown: String) {
    init {
        publicClientWellknown = publicClientWellknown.removeSuffix(".well-known/openid-configuration")
        retailClientWellknown = retailClientWellknown.removeSuffix(".well-known/openid-configuration")
    }
}