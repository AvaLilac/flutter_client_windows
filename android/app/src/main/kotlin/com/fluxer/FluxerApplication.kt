package com.fluxer

import android.app.AlarmManager
import android.app.Application
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import sh.measure.android.Measure
import sh.measure.android.config.MeasureConfig

private const val DATA_TRANSPORT_ALARM_RECEIVER =
    "com.google.android.datatransport.runtime.scheduling.jobscheduling.AlarmManagerSchedulerBroadcastReceiver"

class FluxerApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        val meta = applicationMetaData()
        if (meta?.getString("com.fluxer.PUSH_PROVIDER") == "fcm") {
            cancelStaleDataTransportAlarms()
        }
        if (!measureConfigured(meta)) {
            return
        }
        Measure.init(this, MeasureConfig())
    }

    private fun applicationMetaData(): Bundle? =
        packageManager
            .getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            .metaData

    private fun measureConfigured(meta: Bundle?): Boolean {
        val apiKey = meta?.getString("sh.measure.android.API_KEY")?.trim() ?: ""
        val apiUrl = meta?.getString("sh.measure.android.API_URL")?.trim() ?: ""
        return apiKey.isNotEmpty() && apiUrl.isNotEmpty()
    }

    private fun cancelStaleDataTransportAlarms() {
        val alarmManager = getSystemService(AlarmManager::class.java) ?: return
        val intent =
            Intent().setComponent(ComponentName(this, DATA_TRANSPORT_ALARM_RECEIVER))
        val pending =
            PendingIntent.getBroadcast(
                this,
                0,
                intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
            )
        if (pending != null) {
            alarmManager.cancel(pending)
            pending.cancel()
        }
    }
}
