package com.thalesgroup.apiprotection.restapi


/**
 * This class captures the response from the server, and allows us to emit the result to the UI through
 * live data.
 */
data class Resource<out T>(val status: Status, val data: T?, val message: String?, val exception: Exception? = null) {
    companion object {
        fun <T> success(data: T): Resource<T> = Resource(status = Status.SUCCESS, data = data, message = null)

        fun <T> error(data: T?, message: String, exception: Exception?): Resource<T> =
            Resource(status = Status.ERROR, data = data, message = message, exception = exception)

        fun <T> loading(data: T?): Resource<T> = Resource(status = Status.LOADING, data = data, message = null)
    }
}