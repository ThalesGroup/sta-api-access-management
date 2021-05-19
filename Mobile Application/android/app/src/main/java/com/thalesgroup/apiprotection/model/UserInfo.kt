package com.thalesgroup.apiprotection.model

/**
 * Captures the user info from the JWT Claim
 */
data class UserInfo(val email: String, val name: String)