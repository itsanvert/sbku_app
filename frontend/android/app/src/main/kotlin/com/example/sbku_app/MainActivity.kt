package com.sbkuapp.sbku

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sbkuapp.sbku/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up the method channel for native communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> {
                        result.success(getDeviceInfo())
                    }
                    "getAndroidVersion" -> {
                        result.success(Build.VERSION.RELEASE)
                    }
                    "getDeviceModel" -> {
                        result.success("${Build.MANUFACTURER} ${Build.MODEL}")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun getDeviceInfo(): Map<String, String> {
        return mapOf(
            "device" to Build.DEVICE,
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "product" to Build.PRODUCT,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT.toString(),
            "brand" to Build.BRAND
        )
    }
}
