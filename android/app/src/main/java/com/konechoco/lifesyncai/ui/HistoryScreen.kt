package com.konechoco.lifesyncai.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.DirectionsWalk
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Place
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.konechoco.lifesyncai.R
import com.konechoco.lifesyncai.data.DayLog
import com.konechoco.lifesyncai.data.Store
import java.text.DateFormat

fun formattedDay(key: String): String =
    Store.dateFromKey(key)?.let { DateFormat.getDateInstance(DateFormat.MEDIUM).format(it) } ?: key

@Composable
fun HistoryScreen() {
    val snapshot by Store.state.collectAsState()
    var selected by rememberSaveable { mutableStateOf<String?>(null) }
    val logs = snapshot.days.values.sortedByDescending { it.date }

    val open = selected?.let { snapshot.days[it] }
    if (open != null) {
        BackHandler { selected = null }
        HistoryDetail(open, onBack = { selected = null })
        return
    }

    Column(Modifier.fillMaxSize().padding(horizontal = 16.dp)) {
        Text(
            stringResource(R.string.history_title), color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 16.dp),
        )
        if (logs.isEmpty()) {
            EmptyState(Icons.Filled.History, stringResource(R.string.history_empty))
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                items(logs, key = { it.date }) { log ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(CardColor, RoundedCornerShape(16.dp))
                            .clickable { selected = log.date }
                            .padding(start = 16.dp, top = 12.dp, bottom = 12.dp, end = 4.dp),
                    ) {
                        Column(Modifier.weight(1f)) {
                            Text(formattedDay(log.date), color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                            Row {
                                Text(stringResource(R.string.history_steps, log.steps), color = Cyan, fontSize = 12.sp)
                                Spacer(Modifier.width(16.dp))
                                Text(stringResource(R.string.history_places, log.places.size), color = Purple, fontSize = 12.sp)
                            }
                        }
                        IconButton(onClick = { Store.deleteDay(log.date) }) {
                            Icon(Icons.Filled.Delete, contentDescription = stringResource(R.string.tl_delete), tint = Gray)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun HistoryDetail(log: DayLog, onBack: () -> Unit) {
    val snapshot by Store.state.collectAsState()
    val events = snapshot.events.filter { it.dayKey == log.date }.sortedByDescending { it.time }
    Column(
        Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.history_back), tint = Cyan)
            }
            Text(formattedDay(log.date), color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            MetricCard(stringResource(R.string.steps_today), "${log.steps}", Icons.AutoMirrored.Filled.DirectionsWalk, Cyan, Modifier.weight(1f))
            MetricCard(stringResource(R.string.visited_places), "${log.places.size}", Icons.Filled.Place, Purple, Modifier.weight(1f))
        }
        Card {
            SectionTitle(stringResource(R.string.detail_summary), Icons.Filled.AutoAwesome, Yellow)
            Text(log.summary ?: stringResource(R.string.detail_no_summary), color = Color.White.copy(alpha = 0.9f), fontSize = 14.sp)
        }
        TimelineCard(events, readOnly = true)
        Card {
            SectionTitle(stringResource(R.string.voice_title), Icons.Filled.Mic)
            VoiceNotesList(log.date, readOnly = true)
        }
        Card {
            SectionTitle(stringResource(R.string.detail_places), Icons.Filled.Map, Purple)
            if (log.places.isEmpty()) {
                Text(stringResource(R.string.detail_no_places), color = Gray, fontSize = 14.sp)
            } else {
                log.places.forEach { Text(it, color = Color.White.copy(alpha = 0.85f), fontSize = 12.sp) }
            }
        }
    }
}

@Composable
fun EmptyState(icon: androidx.compose.ui.graphics.vector.ImageVector, text: String) {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(icon, null, tint = Cyan, modifier = Modifier.size(44.dp))
            Spacer(Modifier.size(12.dp))
            Text(text, color = Gray, fontSize = 14.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 32.dp))
        }
    }
}
