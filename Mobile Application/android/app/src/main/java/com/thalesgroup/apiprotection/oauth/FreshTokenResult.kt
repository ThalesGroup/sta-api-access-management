package com.thalesgroup.apiprotection.oauth


data class FreshTokenResult(val accessToken: String?, val idToken: String?, val ex: Exception?) {

    fun isFresh(): Boolean {
        return accessToken != null
    }
}