package com.konechoco.lifesyncai.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsWalk
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Place
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.konechoco.lifesyncai.R
import com.konechoco.lifesyncai.data.Store
import java.text.SimpleDateFormat
import java.util.Locale

/** Statistiche degli ultimi 7 giorni salvati. */
@Composable
fun StatsScreen() {
    val snapshot by Store.state.collectAsState()
    val lastSeven = snapshot.days.values.sortedByDescending { it.date }.take(7).reversed()

    Column(Modifier.fillMaxSize().padding(horizontal = 16.dp)) {
        Text(
            stringResource(R.string.stats_title), color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 16.dp),
        )
        if (lastSeven.isEmpty()) {
            EmptyState(Icons.Filled.BarChart, stringResource(R.string.stats_no_data))
            return
        }
        val average = lastSeven.sumOf { it.steps } / lastSeven.size
        val best = lastSeven.maxBy { it.steps }
        val totalPlaces = lastSeven.sumOf { it.places.size }
        val maxSteps = (lastSeven.maxOf { it.steps }).coerceAtLeast(1)

        Column(
            Modifier.verticalScroll(rememberScrollState()).padding(bottom = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Card {
                Text(stringResource(R.string.stats_last7), color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                Canvas(Modifier.fillMaxWidth().height(200.dp)) {
                    val slot = size.width / lastSeven.size
                    val barWidth = slot * 0.55f
                    lastSeven.forEachIndexed { index, day ->
                        val h = size.height * day.steps / maxSteps
                        drawRoundRect(
                            brush = Brush.verticalGradient(listOf(Purple, Cyan), startY = size.height - h, endY = size.height),
                            topLeft = Offset(slot * index + (slot - barWidth) / 2, size.height - h),
                            size = Size(barWidth, h),
                            cornerRadius = CornerRadius(8f, 8f),
                        )
                    }
                }
                Row(Modifier.fillMaxWidth()) {
                    lastSeven.forEach { day ->
                        Text(
                            shortDay(day.date), color = Gray, fontSize = 11.sp, textAlign = TextAlign.Center,
                            modifier = Modifier.weight(1f),
                        )
                    }
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                MetricCard(stringResource(R.string.stats_average), "$average", Icons.AutoMirrored.Filled.DirectionsWalk, Cyan, Modifier.weight(1f))
                MetricCard(stringResource(R.string.stats_total_places), "$totalPlaces", Icons.Filled.Place, Purple, Modifier.weight(1f))
            }
            Card {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.EmojiEvents, null, tint = Yellow)
                    Text(
                        stringResource(R.string.stats_best_day), color = Yellow, fontSize = 14.sp,
                        modifier = Modifier.padding(start = 8.dp).weight(1f),
                    )
                    Text("${formattedDay(best.date)} · ${best.steps}", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
            }
        }
    }
}

private fun shortDay(key: String): String =
    Store.dateFromKey(key)?.let { SimpleDateFormat("EEE", Locale.getDefault()).format(it) } ?: key
