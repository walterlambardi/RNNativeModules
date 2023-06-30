package com.rnnativemodules

import android.content.Context
import android.os.BatteryManager
import android.provider.Settings
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap

class CustomMethods(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val REACT_CLASS = "CustomMethods"
    }

    override fun getName(): String = REACT_CLASS

    @ReactMethod
    fun getBatteryLevel(promise: Promise) {
        val batteryManager = reactContext.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
        val batteryLevel = batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        if (batteryLevel != null) {
            promise.resolve(batteryLevel)
        } else {
            promise.reject("Battery Level Error", "Unable to retrieve battery level")
        }
    }

    @ReactMethod
    fun getPhoneId(callback: Callback) {
        val phoneId = Settings.Secure.getString(reactContext.contentResolver, Settings.Secure.ANDROID_ID)
        callback.invoke(phoneId)
    }

    @ReactMethod
    fun getDeviceLocation(promise: Promise) {
        val locationManager = reactContext.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        val locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                locationManager?.removeUpdates(this) // Stop listening for further location updates
                val locationData = createLocationData(location)
                promise.resolve(locationData)
            }
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
