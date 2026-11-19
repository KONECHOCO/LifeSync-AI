package com.konechoco.lifesyncai.sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.SystemClock
import androidx.core.content.edit
import com.konechoco.lifesyncai.data.Store
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.Calendar

/**
 * Passi di oggi dal contapassi hardware (TYPE_STEP_COUNTER), che conta anche ad app chiusa.
 * Il sensore restituisce i passi dall'ultimo riavvio: si salva un valore di partenza per ogni giorno.
 */
object StepCounter : SensorEventListener {
    private const val PREFS = "steps"

    private val _steps = MutableStateFlow(0)
    val stepsToday: StateFlow<Int> = _steps.asStateFlow()

    private val _walking = MutableStateFlow(false)
    val isWalking: StateFlow<Boolean> = _walking.asStateFlow()

    private var appContext: Context? = null
    private var lastStepEventAt = 0L
    private var lastPersistAt = 0L

    fun isAvailable(context: Context): Boolean =
        (context.getSystemService(Context.SENSOR_SERVICE) as SensorManager)
            .getDefaultSensor(Sensor.TYPE_STEP_COUNTER) != null

    fun start(context: Context) {
        appContext = context.applicationContext
        val manager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor = manager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) ?: return
        manager.unregisterListener(this)
        manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
        // Mostra subito l'ultimo valore salvato, in attesa del primo evento del sensore
        val saved = Store.state.value.days[Store.dayKey()]?.steps ?: 0
        if (saved > _steps.value) _steps.value = saved
    }

    fun stop(context: Context) {
        (context.getSystemService(Context.SENSOR_SERVICE) as SensorManager).unregisterListener(this)
        persist(force = true)
        _walking.value = false
    }

    /** Da chiamare periodicamente: "camminata" se c'è stato un passo negli ultimi 20 secondi. */
    fun refreshWalking() {
        _walking.value = SystemClock.elapsedRealtime() - lastStepEventAt < 20_000
    }

    override fun onSensorChanged(event: SensorEvent) {
        val context = appContext ?: return
        val total = event.values.firstOrNull()?.toLong() ?: return
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val today = Store.dayKey()

        var baseDay = prefs.getString("baseDay", null)
        var baseValue = prefs.getLong("baseValue", total)
        var offset = prefs.getLong("offset", 0)
        val lastValue = prefs.getLong("lastValue", -1)
        val lastDay = prefs.getString("lastDay", null)

        if (baseDay != today) {
            // Nuovo giorno: se ieri l'app ha letto il sensore, si parte dall'ultimo valore letto.
            baseValue = if (lastDay == yesterdayKey() && lastValue in 0..total) lastValue else total
            offset = 0
            baseDay = today
        } else if (lastValue >= 0 && total < lastValue) {
            // Il telefono è stato riavviato: il contatore è ripartito da zero.
            offset += lastValue - baseValue
            baseValue = 0
        }

        val steps = (offset + total - baseValue).coerceAtLeast(0).toInt()
        prefs.edit {
            putString("baseDay", baseDay)
            putLong("baseValue", baseValue)
            putLong("offset", offset)
            putLong("lastValue", total)
            putString("lastDay", today)
        }

        if (steps != _steps.value) {
            if (_steps.value != 0 || steps > 0) lastStepEventAt = SystemClock.elapsedRealtime()
            _steps.value = steps
        }
        refreshWalking()
        persist(force = false)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun persist(force: Boolean) {
        val now = SystemClock.elapsedRealtime()
        if (!force && now - lastPersistAt < 15_000) return
        lastPersistAt = now
        if (_steps.value > 0) Store.upsertDay(Store.dayKey(), steps = _steps.value)
    }

    private fun yesterdayKey(): String {
        val cal = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -1) }
        return Store.dayKey(cal.timeInMillis)
    }
}
