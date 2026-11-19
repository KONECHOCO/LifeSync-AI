package com.konechoco.lifesyncai.sensors

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.location.LocationManager
import android.os.Build
import androidx.core.content.ContextCompat
import androidx.core.content.edit
import androidx.core.location.LocationManagerCompat
import com.konechoco.lifesyncai.R
import com.konechoco.lifesyncai.data.Store
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import java.text.DateFormat
import java.util.Date
import java.util.Locale
import kotlin.coroutines.resume

/**
 * Luoghi visitati, registrati solo quando l'app è aperta (nessun accesso alla posizione in background).
 * Una nuova visita viene salvata se ci si è spostati di almeno 200 m dall'ultimo luogo registrato.
 */
object PlaceTracker {
    private const val PREFS = "places"
    private const val MIN_DISTANCE_METERS = 200f

    fun hasPermission(context: Context): Boolean =
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED

    /** Legge la posizione attuale e, se è un luogo nuovo, lo aggiunge al diario di oggi. */
    suspend fun captureVisit(context: Context) {
        if (!hasPermission(context)) return
        val location = currentLocation(context) ?: return
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val today = Store.dayKey()
        val lastDay = prefs.getString("lastDay", null)
        if (lastDay == today) {
            val last = Location("saved").apply {
                latitude = prefs.getFloat("lastLat", 0f).toDouble()
                longitude = prefs.getFloat("lastLon", 0f).toDouble()
            }
            if (last.distanceTo(location) < MIN_DISTANCE_METERS) return
        }

        val coordinates = String.format(Locale.US, "%.3f, %.3f", location.latitude, location.longitude)
        val name = placeName(context, location) ?: coordinates
        val now = System.currentTimeMillis()
        val time = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(now))

        Store.upsertDay(today, places = listOf("[$time] $name"))
        Store.addEvent(
            kind = "visit",
            title = "${context.getString(R.string.tl_visit)}: $name",
            detail = coordinates,
            time = now,
            id = "visit-$now",
        )
        prefs.edit {
            putString("lastDay", today)
            putFloat("lastLat", location.latitude.toFloat())
            putFloat("lastLon", location.longitude.toFloat())
        }
    }

    @SuppressLint("MissingPermission")
    private suspend fun currentLocation(context: Context): Location? {
        val manager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val provider = listOfNotNull(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) LocationManager.FUSED_PROVIDER else null,
            LocationManager.NETWORK_PROVIDER,
            LocationManager.GPS_PROVIDER,
        ).firstOrNull { runCatching { manager.isProviderEnabled(it) }.getOrDefault(false) } ?: return null

        val fresh: Location? = withTimeoutOrNull(15_000L) {
            suspendCancellableCoroutine<Location?> { cont ->
                val cancel = android.os.CancellationSignal()
                cont.invokeOnCancellation { cancel.cancel() }
                LocationManagerCompat.getCurrentLocation(
                    manager,
                    provider,
                    cancel,
                    ContextCompat.getMainExecutor(context),
                    androidx.core.util.Consumer<Location?> { location -> if (cont.isActive) cont.resume(location) },
                )
            }
        }
        return fresh ?: runCatching { manager.getLastKnownLocation(provider) }.getOrNull()
    }

    private suspend fun placeName(context: Context, location: Location): String? = withContext(Dispatchers.IO) {
        if (!Geocoder.isPresent()) return@withContext null
        runCatching {
            @Suppress("DEPRECATION")
            val address = Geocoder(context, Locale.getDefault()).getFromLocation(location.latitude, location.longitude, 1)?.firstOrNull()
            listOfNotNull(address?.thoroughfare, address?.locality).joinToString(", ").ifBlank { address?.featureName }
        }.getOrNull()
    }
}
