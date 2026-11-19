package com.konechoco.lifesyncai.ui

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.os.Build
import android.speech.RecognizerIntent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsWalk
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.TableChart
import androidx.compose.material.icons.filled.Timeline
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.edit
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.konechoco.lifesyncai.Exporter
import com.konechoco.lifesyncai.R
import com.konechoco.lifesyncai.Summary
import com.konechoco.lifesyncai.ads.AdsManager
import com.konechoco.lifesyncai.billing.BillingManager
import com.konechoco.lifesyncai.data.Store
import com.konechoco.lifesyncai.data.TimelineEvent
import com.konechoco.lifesyncai.sensors.PlaceTracker
import com.konechoco.lifesyncai.sensors.StepCounter
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.DateFormat
import java.util.Date

@Composable
fun TodayScreen(activity: Activity) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val snapshot by Store.state.collectAsState()
    val steps by StepCounter.stepsToday.collectAsState()
    val walking by StepCounter.isWalking.collectAsState()
    val isPro by BillingManager.isPro.collectAsState()
    val startupDone by AdsManager.startupDone.collectAsState()

    val today = Store.dayKey()
    val day = snapshot.days[today]
    val events = snapshot.events.filter { it.dayKey == today }.sortedByDescending { it.time }
    val notesCount = snapshot.notes.count { it.dayKey == today }
    val places = day?.places?.size ?: 0

    var showPaywall by remember { mutableStateOf(false) }
    var exportError by remember { mutableStateOf(false) }
    var voiceMessage by remember { mutableStateOf<Int?>(null) }
    val prefs = remember { context.getSharedPreferences("settings", Context.MODE_PRIVATE) }
    var permissionsAsked by remember { mutableStateOf(prefs.getBoolean("permissionsAsked", false)) }

    val permissionLauncher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
        StepCounter.start(context)
        scope.launch { PlaceTracker.captureVisit(context) }
    }
    val voiceLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val text = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()?.trim()
        when {
            result.resultCode != Activity.RESULT_OK -> voiceMessage = R.string.voice_err_perm
            text.isNullOrEmpty() -> voiceMessage = R.string.voice_err_empty
            else -> {
                Store.addNote(text)
                voiceMessage = null
            }
        }
    }

    fun requestPermissions() {
        prefs.edit { putBoolean("permissionsAsked", true) }
        permissionsAsked = true
        val wanted = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) add(Manifest.permission.ACTIVITY_RECOGNITION)
            add(Manifest.permission.ACCESS_FINE_LOCATION)
            add(Manifest.permission.ACCESS_COARSE_LOCATION)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) add(Manifest.permission.POST_NOTIFICATIONS)
        }
        permissionLauncher.launch(wanted.toTypedArray())
    }

    // Sensori attivi solo con l'app in primo piano
    val lifecycleOwner = LocalLifecycleOwner.current
    androidx.compose.runtime.DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_RESUME -> {
                    StepCounter.start(context)
                    scope.launch { PlaceTracker.captureVisit(context) }
                }
                Lifecycle.Event.ON_PAUSE -> StepCounter.stop(context)
                else -> Unit
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
            StepCounter.stop(context)
        }
    }
    LaunchedEffect(Unit) {
        while (true) {
            delay(5_000)
            StepCounter.refreshWalking()
        }
    }

    fun generateSummary() {
        Store.upsertDay(today, steps = steps)
        val text = Summary.make(context, steps, places, Store.averageSteps(today), notesCount)
        Store.upsertDay(today, summary = text)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        // Intestazione
        Card {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text(
                        "${stringResource(R.string.today_label)}, ${DateFormat.getDateInstance(DateFormat.MEDIUM).format(Date())}",
                        color = Cyan, fontSize = 12.sp, fontWeight = FontWeight.Bold,
                    )
                    Text(stringResource(R.string.app_title), color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .background(Green.copy(alpha = 0.15f), RoundedCornerShape(20.dp))
                        .padding(horizontal = 10.dp, vertical = 5.dp),
                ) {
                    Box(Modifier.size(8.dp).clip(CircleShape).background(Green))
                    Spacer(Modifier.width(6.dp))
                    Text(stringResource(R.string.active_status), color = Green, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }

        // Spiegazione prima delle richieste di permesso (mostrata una volta, dopo consenso e annuncio d'apertura)
        if (!permissionsAsked && startupDone) {
            Card(color = Cyan.copy(alpha = 0.10f)) {
                SectionTitle(stringResource(R.string.perm_title), Icons.Filled.Shield, Cyan)
                Text(stringResource(R.string.perm_body), color = Color.White.copy(alpha = 0.85f), fontSize = 13.sp)
                Button(onClick = { requestPermissions() }, colors = ButtonDefaults.buttonColors(containerColor = Cyan)) {
                    Text(stringResource(R.string.perm_button), color = Color.Black, fontWeight = FontWeight.Bold)
                }
            }
        }

        // Metriche
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            MetricCard(stringResource(R.string.steps_today), "$steps", Icons.AutoMirrored.Filled.DirectionsWalk, Cyan, Modifier.weight(1f))
            MetricCard(stringResource(R.string.visited_places), "$places", Icons.Filled.Place, Purple, Modifier.weight(1f))
            MetricCard(stringResource(R.string.voice_notes_count), "$notesCount", Icons.Filled.Mic, Orange, Modifier.weight(1f))
        }

        // Attività rilevata
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.White.copy(alpha = 0.04f), RoundedCornerShape(16.dp))
                .padding(16.dp),
        ) {
            Icon(Icons.AutoMirrored.Filled.DirectionsWalk, null, tint = Gray, modifier = Modifier.size(18.dp))
            Spacer(Modifier.width(8.dp))
            Text(stringResource(R.string.detected_activity), color = Gray, fontSize = 14.sp, modifier = Modifier.weight(1f))
            Text(
                stringResource(if (walking) R.string.act_walking else R.string.act_still),
                color = Cyan, fontSize = 14.sp, fontWeight = FontWeight.Bold,
            )
        }

        TimelineCard(events, readOnly = false)

        // Note vocali
        Card {
            SectionTitle(stringResource(R.string.voice_title), Icons.Filled.Mic, Color.White) {
                TextButton(onClick = {
                    val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                        putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
                    }
                    try {
                        voiceLauncher.launch(intent)
                    } catch (_: ActivityNotFoundException) {
                        voiceMessage = R.string.voice_err_unsupported
                    }
                }) {
                    Icon(Icons.Filled.Mic, null, tint = Pink, modifier = Modifier.size(16.dp))
                    Spacer(Modifier.width(4.dp))
                    Text(stringResource(R.string.voice_record), color = Pink, fontSize = 13.sp)
                }
            }
            Text(
                stringResource(voiceMessage ?: R.string.voice_desc),
                color = if (voiceMessage == null) Gray else Orange, fontSize = 12.sp,
            )
            VoiceNotesList(today, readOnly = false)
        }

        // Riepilogo
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF1E3A8A).copy(alpha = 0.18f), RoundedCornerShape(20.dp))
                .border(1.dp, Yellow.copy(alpha = 0.3f), RoundedCornerShape(20.dp))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            SectionTitle(stringResource(R.string.ai_summary), Icons.Filled.AutoAwesome, Yellow) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .clip(RoundedCornerShape(10.dp))
                        .background(AccentGradient)
                        .combinedClickable(onClick = {
                            AdsManager.showRewarded(activity) { earned ->
                                if (earned) generateSummary() else showPaywall = true
                            }
                        })
                        .padding(horizontal = 12.dp, vertical = 7.dp),
                ) {
                    Icon(Icons.Filled.Refresh, null, tint = Color.White, modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(5.dp))
                    Text(
                        stringResource(if (isPro) R.string.generate_now else R.string.watch_ad_unlock),
                        color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold,
                    )
                }
            }
            Text(
                day?.summary ?: stringResource(R.string.ai_placeholder),
                color = Color.White.copy(alpha = 0.9f), fontSize = 14.sp, lineHeight = 20.sp,
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.Black.copy(alpha = 0.4f), RoundedCornerShape(12.dp))
                    .padding(14.dp),
            )
        }

        // Backup ed export
        Card {
            SectionTitle(stringResource(R.string.daily_backup_status), Icons.Filled.Shield, Green)
            Text(stringResource(R.string.backup_desc), color = Gray, fontSize = 12.sp)
            Text(stringResource(R.string.places_note), color = Gray, fontSize = 12.sp)
            ActionButton(stringResource(R.string.export_backup), Icons.Filled.Share, enabled = true) {
                Store.upsertDay(today, steps = steps)
                if (!Exporter.share(context, csv = false)) exportError = true
            }
            ActionButton(stringResource(R.string.export_csv), if (isPro) Icons.Filled.TableChart else Icons.Filled.Lock, enabled = isPro) {
                if (!isPro) {
                    showPaywall = true
                } else {
                    Store.upsertDay(today, steps = steps)
                    if (!Exporter.share(context, csv = true)) exportError = true
                }
            }
        }
    }

    if (showPaywall) PaywallDialog(activity, onDismiss = { showPaywall = false })
    if (exportError) {
        AlertDialog(
            onDismissRequest = { exportError = false },
            confirmButton = { TextButton(onClick = { exportError = false }) { Text(stringResource(R.string.pw_ok)) } },
            title = { Text(stringResource(R.string.pw_error_title)) },
            text = { Text(stringResource(R.string.export_error)) },
        )
    }
}

@Composable
private fun ActionButton(text: String, icon: ImageVector, enabled: Boolean, onClick: () -> Unit) {
    Row(
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .background(Color.White.copy(alpha = 0.08f))
            .combinedClickable(onClick = onClick)
            .padding(vertical = 11.dp),
    ) {
        val tint = if (enabled) Color.White else Gray
        Icon(icon, null, tint = tint, modifier = Modifier.size(16.dp))
        Spacer(Modifier.width(6.dp))
        Text(text, color = tint, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
    }
}

/** Timeline di un giorno: visite, eventi manuali, note vocali. Pressione lunga per eliminare. */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun TimelineCard(events: List<TimelineEvent>, readOnly: Boolean) {
    var menuOpen by remember { mutableStateOf(false) }
    var deleteTarget by remember { mutableStateOf<TimelineEvent?>(null) }
    val manual = listOf(R.string.tl_office, R.string.tl_gym, R.string.tl_home, R.string.tl_call, R.string.tl_lunch)
    val context = LocalContext.current

    Card {
        SectionTitle(stringResource(R.string.tl_title), Icons.Filled.Timeline) {
            if (!readOnly) {
                Box {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .clip(RoundedCornerShape(10.dp))
                            .background(Cyan.copy(alpha = 0.18f))
                            .combinedClickable(onClick = { menuOpen = true })
                            .padding(horizontal = 10.dp, vertical = 6.dp),
                    ) {
                        Icon(Icons.Filled.Add, null, tint = Cyan, modifier = Modifier.size(14.dp))
                        Spacer(Modifier.width(4.dp))
                        Text(stringResource(R.string.tl_add), color = Cyan, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                    }
                    DropdownMenu(expanded = menuOpen, onDismissRequest = { menuOpen = false }) {
                        manual.forEach { res ->
                            DropdownMenuItem(text = { Text(stringResource(res)) }, onClick = {
                                menuOpen = false
                                Store.addEvent(kind = "manual", title = context.getString(res), detail = context.getString(R.string.tl_manual))
                            })
                        }
                    }
                }
            }
        }
        if (events.isEmpty()) {
            Text(stringResource(R.string.tl_empty), color = Gray, fontSize = 12.sp)
        } else {
            events.take(if (readOnly) 100 else 12).forEach { event ->
                Row(
                    verticalAlignment = Alignment.Top,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White.copy(alpha = 0.04f))
                        .combinedClickable(onClick = {}, onLongClick = { if (!readOnly) deleteTarget = event })
                        .padding(10.dp),
                ) {
                    Text(
                        DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(event.time)),
                        color = Cyan, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, modifier = Modifier.width(50.dp),
                    )
                    val (icon, color) = when (event.kind) {
                        "visit" -> Icons.Filled.Place to Purple
                        "voice" -> Icons.Filled.Mic to Pink
                        else -> Icons.Filled.Edit to Orange
                    }
                    Icon(icon, null, tint = color, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(10.dp))
                    Column {
                        val title = if (event.kind == "voice") stringResource(R.string.voice_title) else event.title
                        Text(title, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                        if (event.detail.isNotEmpty()) Text(event.detail, color = Gray, fontSize = 12.sp)
                    }
                }
            }
        }
    }

    deleteTarget?.let { target ->
        AlertDialog(
            onDismissRequest = { deleteTarget = null },
            confirmButton = {
                TextButton(onClick = {
                    if (target.kind == "voice") Store.deleteNote(target.id.removePrefix("voice-")) else Store.deleteEvent(target.id)
                    deleteTarget = null
                }) { Text(stringResource(R.string.tl_delete), color = Color(0xFFF87171)) }
            },
            dismissButton = { TextButton(onClick = { deleteTarget = null }) { Text(stringResource(R.string.set_cancel)) } },
            text = { Text(if (target.kind == "voice") target.detail else target.title) },
        )
    }
}

@Composable
fun VoiceNotesList(dayKey: String, readOnly: Boolean) {
    val snapshot by Store.state.collectAsState()
    val notes = snapshot.notes.filter { it.dayKey == dayKey }.sortedByDescending { it.time }
    if (notes.isEmpty()) {
        if (readOnly) Text(stringResource(R.string.voice_empty), color = Gray, fontSize = 12.sp)
        return
    }
    notes.forEach { note ->
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.White.copy(alpha = 0.04f), RoundedCornerShape(12.dp))
                .padding(10.dp),
        ) {
            Text(DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(note.time)), color = Cyan, fontSize = 11.sp)
            Text(note.text, color = Color.White.copy(alpha = 0.9f), fontSize = 14.sp)
        }
    }
}
