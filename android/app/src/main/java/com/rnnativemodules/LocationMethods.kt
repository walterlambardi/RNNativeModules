package com.rnnativemodules

import android.content.Context
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import android.os.Bundle

class LocationMethods(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val REACT_CLASS = "LocationMethods"
    }

    override fun getName(): String = REACT_CLASS

    @ReactMethod
    fun getDeviceLocation(promise: Promise) {
        val locationManager = reactContext.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        val locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                locationManager?.removeUpdates(this) // Stop listening for further location updates
                val locationData = createLocationData(location)
                promise.resolve(locationData)
            }

            override fun onStatusChanged(provider: String, status: Int, extras: Bundle) {}
            override fun onProviderEnabled(provider: String) {}
            override fun onProviderDisabled(provider: String) {}
        }

        try {
            // Request location updates
            locationManager?.requestSingleUpdate(LocationManager.NETWORK_PROVIDER, locationListener, null)
            locationManager?.requestSingleUpdate(LocationManager.GPS_PROVIDER, locationListener, null)
        } catch (e: SecurityException) {
            promise.reject("Location Permission Error", "Location permission not granted.")
        }
    }

    private fun createLocationData(location: Location): WritableMap {
        val locationData = Arguments.createMap()
        locationData.putDouble("latitude", location.latitude)
        locationData.putDouble("longitude", location.longitude)
        return locationData
    }
}
