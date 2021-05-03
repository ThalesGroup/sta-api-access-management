package com.thalesgroup.gartnersample.oauth


data class FreshTokenResult(val accessToken: String?, val idToken: String?, val ex: Exception?) {

    fun isFresh(): Boolean {
        return accessToken != null
    }
}