package com.fluxer

import android.app.Application
import android.content.pm.PackageManager
import sh.measure.android.Measure
import sh.measure.android.config.MeasureConfig

class FluxerApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (!measureConfigured()) {
            return
        }
        Measure.init(this, MeasureConfig())
    }

    private fun measureConfigured(): Boolean {
        val meta =
            packageManager
                .getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                .metaData
        val apiKey = meta?.getString("sh.measure.android.API_KEY")?.trim() ?: ""
        val apiUrl = meta?.getString("sh.measure.android.API_URL")?.trim() ?: ""
        return apiKey.isNotEmpty() && apiUrl.isNotEmpty()
    }
}
