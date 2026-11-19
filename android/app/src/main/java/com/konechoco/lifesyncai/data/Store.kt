package com.konechoco.lifesyncai.data

import android.content.Context
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.UUID

/** Giorno salvato: passi, luoghi e riepilogo. */
data class DayLog(
    val date: String,
    val steps: Int = 0,
    val places: List<String> = emptyList(),
    val summary: String? = null,
)

/** Evento della timeline: visita, evento manuale, nota vocale. */
data class TimelineEvent(
    val id: String,
    val time: Long,
    val dayKey: String,
    val kind: String,
    val title: String,
    val detail: String,
)

/** Nota vocale trascritta (l'audio non viene conservato). */
data class VoiceNote(
    val id: String,
    val time: Long,
    val dayKey: String,
    val text: String,
)

data class Snapshot(
    val days: Map<String, DayLog> = emptyMap(),
    val events: List<TimelineEvent> = emptyList(),
    val notes: List<VoiceNote> = emptyList(),
)

/**
 * Archivio locale in un file JSON privato dell'app: i dati restano sul dispositivo.
 * Ogni modifica pubblica una nuova [Snapshot] osservabile dalle schermate.
 */
object Store {
    private lateinit var file: File
    private val _state = MutableStateFlow(Snapshot())
    val state: StateFlow<Snapshot> = _state.asStateFlow()

    fun init(context: Context) {
        file = File(context.filesDir, "lifesync.json")
        _state.value = load()
    }

    fun dayKey(time: Long = System.currentTimeMillis()): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date(time))

    fun dateFromKey(key: String): Date? = runCatching {
        SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(key)
    }.getOrNull()

    @Synchronized
    fun upsertDay(key: String, steps: Int? = null, places: List<String>? = null, summary: String? = null) {
        val current = _state.value
        val existing = current.days[key] ?: DayLog(date = key)
        val mergedPlaces = if (places == null) existing.places else existing.places + places.filter { it !in existing.places }
        val updated = existing.copy(
            steps = steps?.coerceAtLeast(0) ?: existing.steps,
            places = mergedPlaces,
            summary = summary ?: existing.summary,
        )
        commit(current.copy(days = current.days + (key to updated)))
    }

    @Synchronized
    fun addEvent(kind: String, title: String, detail: String, time: Long = System.currentTimeMillis(), id: String = UUID.randomUUID().toString()) {
        val current = _state.value
        val event = TimelineEvent(id, time, dayKey(time), kind, title, detail)
        val events = current.events.filterNot { it.id == id } + event
        commit(current.copy(events = events))
    }

    @Synchronized
    fun deleteEvent(id: String) {
        val current = _state.value
        commit(current.copy(events = current.events.filterNot { it.id == id }))
    }

    @Synchronized
    fun addNote(text: String): VoiceNote {
        val current = _state.value
        val now = System.currentTimeMillis()
        val note = VoiceNote(UUID.randomUUID().toString(), now, dayKey(now), text)
        commit(current.copy(notes = current.notes + note))
        addEvent(kind = "voice", title = "", detail = text, time = now, id = "voice-${note.id}")
        return note
    }

    @Synchronized
    fun deleteNote(id: String) {
        val current = _state.value
        commit(
            current.copy(
                notes = current.notes.filterNot { it.id == id },
                events = current.events.filterNot { it.id == "voice-$id" },
            )
        )
    }

    @Synchronized
    fun deleteDay(key: String) {
        val current = _state.value
        commit(current.copy(days = current.days - key))
    }

    @Synchronized
    fun deleteAll() {
        commit(Snapshot())
    }

    /** Media passi degli ultimi 7 giorni salvati, escluso oggi. */
    fun averageSteps(excluding: String): Int? {
        val previous = _state.value.days.values
            .filter { it.date != excluding && it.steps > 0 }
            .sortedByDescending { it.date }
            .take(7)
        if (previous.isEmpty()) return null
        return previous.sumOf { it.steps } / previous.size
    }

    fun eventsFor(key: String): List<TimelineEvent> =
        _state.value.events.filter { it.dayKey == key }.sortedByDescending { it.time }

    fun notesFor(key: String): List<VoiceNote> =
        _state.value.notes.filter { it.dayKey == key }.sortedByDescending { it.time }

    // ---------- Export ----------

    fun exportJson(): String {
        val iso = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.US).apply { timeZone = TimeZone.getDefault() }
        val snapshot = _state.value
        val root = JSONObject()
        root.put("days", JSONArray().apply {
            snapshot.days.values.sortedBy { it.date }.forEach { day ->
                put(JSONObject().apply {
                    put("date", day.date)
                    put("steps", day.steps)
                    put("places", JSONArray(day.places))
                    put("summary", day.summary ?: "")
                })
            }
        })
        root.put("timeline", JSONArray().apply {
            snapshot.events.sortedBy { it.time }.forEach { event ->
                put(JSONObject().apply {
                    put("time", iso.format(Date(event.time)))
                    put("type", event.kind)
                    put("title", event.title)
                    put("detail", event.detail)
                })
            }
        })
        root.put("voice_notes", JSONArray().apply {
            snapshot.notes.sortedBy { it.time }.forEach { note ->
                put(JSONObject().apply {
                    put("time", iso.format(Date(note.time)))
                    put("text", note.text)
                })
            }
        })
        return root.toString(2)
    }

    fun exportCsv(): String {
        fun esc(field: String): String =
            if (field.contains(',') || field.contains('"') || field.contains('\n')) "\"" + field.replace("\"", "\"\"") + "\"" else field
        val lines = mutableListOf("date,steps,places,summary")
        _state.value.days.values.sortedBy { it.date }.forEach { day ->
            lines += listOf(day.date, day.steps.toString(), esc(day.places.joinToString("; ")), esc(day.summary ?: "")).joinToString(",")
        }
        return lines.joinToString("\n")
    }

    // ---------- Persistenza ----------

    private fun commit(snapshot: Snapshot) {
        _state.value = snapshot
        runCatching { file.writeText(serialize(snapshot)) }
    }

    private fun load(): Snapshot = runCatching {
        if (!file.exists()) return Snapshot()
        val root = JSONObject(file.readText())
        val days = mutableMapOf<String, DayLog>()
        root.optJSONArray("days")?.let { arr ->
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                val places = o.optJSONArray("places")?.let { p -> List(p.length()) { p.getString(it) } } ?: emptyList()
                val summary = o.optString("summary").takeIf { it.isNotEmpty() }
                days[o.getString("date")] = DayLog(o.getString("date"), o.optInt("steps"), places, summary)
            }
        }
        val events = root.optJSONArray("events")?.let { arr ->
            List(arr.length()) { i ->
                val o = arr.getJSONObject(i)
                TimelineEvent(o.getString("id"), o.getLong("time"), o.getString("dayKey"), o.getString("kind"), o.optString("title"), o.optString("detail"))
            }
        } ?: emptyList()
        val notes = root.optJSONArray("notes")?.let { arr ->
            List(arr.length()) { i ->
                val o = arr.getJSONObject(i)
                VoiceNote(o.getString("id"), o.getLong("time"), o.getString("dayKey"), o.getString("text"))
            }
        } ?: emptyList()
        Snapshot(days, events, notes)
    }.getOrElse { Snapshot() }

    private fun serialize(snapshot: Snapshot): String {
        val root = JSONObject()
        root.put("days", JSONArray().apply {
            snapshot.days.values.forEach { day ->
                put(JSONObject().apply {
                    put("date", day.date)
                    put("steps", day.steps)
                    put("places", JSONArray(day.places))
                    put("summary", day.summary ?: "")
                })
            }
        })
        root.put("events", JSONArray().apply {
            snapshot.events.forEach { e ->
                put(JSONObject().apply {
                    put("id", e.id); put("time", e.time); put("dayKey", e.dayKey)
                    put("kind", e.kind); put("title", e.title); put("detail", e.detail)
                })
            }
        })
        root.put("notes", JSONArray().apply {
            snapshot.notes.forEach { n ->
                put(JSONObject().apply {
                    put("id", n.id); put("time", n.time); put("dayKey", n.dayKey); put("text", n.text)
                })
            }
        })
        return root.toString()
    }
}
