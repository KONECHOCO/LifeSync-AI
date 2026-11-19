package com.konechoco.lifesyncai.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.content.edit
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.konechoco.lifesyncai.MainActivity
import com.konechoco.lifesyncai.R
import java.util.Calendar
import java.util.concurrent.TimeUnit

/** Promemoria serale per il riepilogo giornaliero (default: attivo alle 23:00). */
object NightlyReminder {
    private const val CHANNEL_ID = "daily_summary"
    private const val WORK_NAME = "nightly_summary"
    private const val PREFS = "settings"
    const val KEY_ENABLED = "nightlyEnabled"
    const val KEY_MINUTES = "nightlyMinutes"

    fun isEnabled(context: Context) = prefs(context).getBoolean(KEY_ENABLED, true)
    fun minutes(context: Context) = prefs(context).getInt(KEY_MINUTES, 23 * 60)

    fun update(context: Context, enabled: Boolean, minutes: Int) {
        prefs(context).edit {
            putBoolean(KEY_ENABLED, enabled)
            putInt(KEY_MINUTES, minutes)
        }
        scheduleFromSettings(context)
    }

    fun createChannel(context: Context) {
        val channel = NotificationChannel(CHANNEL_ID, context.getString(R.string.notif_channel), NotificationManager.IMPORTANCE_DEFAULT)
        context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    fun scheduleFromSettings(context: Context) {
        val workManager = WorkManager.getInstance(context)
        if (!isEnabled(context)) {
            workManager.cancelUniqueWork(WORK_NAME)
            return
        }
        val minutes = minutes(context)
        val now = Calendar.getInstance()
        val next = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, minutes / 60)
            set(Calendar.MINUTE, minutes % 60)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (!after(now)) add(Calendar.DAY_OF_YEAR, 1)
        }
        val request = OneTimeWorkRequestBuilder<NightlyWorker>()
            .setInitialDelay(next.timeInMillis - now.timeInMillis, TimeUnit.MILLISECONDS)
            .build()
        workManager.enqueueUniqueWork(WORK_NAME, ExistingWorkPolicy.REPLACE, request)
    }

    fun show(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) return

        val intent = PendingIntent.getActivity(
            context, 0,
            Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(context.getString(R.string.notif_title))
            .setContentText(context.getString(R.string.notif_body))
            .setContentIntent(intent)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(context).notify(1, notification)
    }

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}

class NightlyWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        NightlyReminder.show(applicationContext)
        NightlyReminder.scheduleFromSettings(applicationContext)
        return Result.success()
    }
}
