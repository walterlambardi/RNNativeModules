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

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.ActivityEventListener
import com.facebook.react.bridge.BaseActivityEventListener
import com.google.zxing.integration.android.IntentIntegrator
import com.google.zxing.integration.android.IntentResult
import android.app.Activity
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

class CustomMethods(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val REACT_CLASS = "CustomMethods"
        const val SCAN_QR_REQUEST_CODE = 1
    }

    private var qrCodePromise: Promise? = null

    override fun getName(): String = REACT_CLASS

    override fun getConstants(): MutableMap<String, Any> {
        return hashMapOf("SCAN_QR_REQUEST_CODE" to SCAN_QR_REQUEST_CODE)
    }

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

    @ReactMethod
    fun scanQRCode(promise: Promise) {
        qrCodePromise = promise

        if (ContextCompat.checkSelfPermission(
                reactContext,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                reactContext.currentActivity!!,
                arrayOf(Manifest.permission.CAMERA),
                SCAN_QR_REQUEST_CODE
            )
        } else {
            startScanQRActivity()
        }
    }

    private fun startScanQRActivity() {
        val scanQRIntent = Intent(reactContext, ScanQRActivity::class.java)
        reactContext.currentActivity?.startActivityForResult(scanQRIntent, SCAN_QR_REQUEST_CODE)
    }

    private val activityEventListener: ActivityEventListener = object : BaseActivityEventListener() {
        override fun onActivityResult(activity: Activity?, requestCode: Int, resultCode: Int, data: Intent?) {
            super.onActivityResult(activity, requestCode, resultCode, data)

            if (requestCode == SCAN_QR_REQUEST_CODE) {
                if (resultCode == Activity.RESULT_OK) {
                    val qrCode = data?.getStringExtra("qrCode")
                    qrCodePromise?.resolve(qrCode)
                } else {
                    qrCodePromise?.reject("Scan Error", "Failed to scan QR code")
                }
                qrCodePromise = null
            }
        }
    }

    init {
        reactContext.addActivityEventListener(activityEventListener)
    }

    class ScanQRActivity : Activity() {

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            // Initialize the QR code scanning process
            IntentIntegrator(this@ScanQRActivity).initiateScan()
        }

        override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
            super.onActivityResult(requestCode, resultCode, data)
            // Handle the result of the QR code scanning process
            val result: IntentResult? =
                IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            if (result != null && result.contents != null) {
                // QR code scanned successfully
                val qrCode = result.contents
                val returnIntent = Intent().apply {
                    putExtra("qrCode", qrCode)
                }
                setResult(Activity.RESULT_OK, returnIntent)
            } else {
                // Failed to scan QR code
                setResult(Activity.RESULT_CANCELED)
            }
            finish()
        }
    }
}
