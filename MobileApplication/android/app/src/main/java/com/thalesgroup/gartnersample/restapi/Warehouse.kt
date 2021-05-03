package com.thalesgroup.gartnersample.restapi

import com.google.android.gms.maps.model.LatLng
import java.lang.Double.parseDouble

data class Warehouse(var description: String, val id: String, val name: String, val location: String) {
    fun getLatLng(): LatLng {
        val latlong =  location.split(',')
        val latitude = parseDouble(latlong[0])
        val longitude = parseDouble(latlong[1])
        return LatLng(latitude, longitude)
    }
}