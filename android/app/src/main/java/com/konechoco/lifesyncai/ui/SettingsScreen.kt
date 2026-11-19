package com.konechoco.lifesyncai.ui

import android.Manifest
import android.app.Activity
import android.app.TimePickerDialog
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.text.format.DateFormat
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.konechoco.lifesyncai.BuildConfig
import com.konechoco.lifesyncai.R
import com.konechoco.lifesyncai.ads.AdsManager
import com.konechoco.lifesyncai.billing.BillingManager
import com.konechoco.lifesyncai.data.Store
import com.konechoco.lifesyncai.notifications.NightlyReminder
import java.util.Calendar

@Composable
fun SettingsScreen(activity: Activity) {
    val context = LocalContext.current
    val isPro by BillingManager.isPro.collectAsState()
    val privacyRequired by AdsManager.privacyOptionsRequired.collectAsState()
    val testAds by AdsManager.testAds.collectAsState()
    val diagnostics by AdsManager.diagnostics.collectAsState()

    var enabled by remember { mutableStateOf(NightlyReminder.isEnabled(context)) }
    var minutes by remember { mutableIntStateOf(NightlyReminder.minutes(context)) }
    var testSent by remember { mutableStateOf(false) }
    var confirmDelete by remember { mutableStateOf(false) }
    var versionTaps by remember { mutableIntStateOf(0) }

    val notificationPermission = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { }
    fun ensureNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            notificationPermission.launch(Manifest.permission.POST_NOTIFICATIONS)
        }
    }

    Column(
        Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(stringResource(R.string.tab_settings), color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold)

        Section(stringResource(R.string.set_notifications)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(stringResource(R.string.set_notif_toggle), color = Color.White, modifier = Modifier.weight(1f))
                Switch(
                    checked = enabled,
                    onCheckedChange = {
                        enabled = it
                        NightlyReminder.update(context, it, minutes)
                        if (it) ensureNotificationPermission()
                    },
                    colors = SwitchDefaults.colors(checkedTrackColor = Cyan),
                )
            }
            if (enabled) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth().clickable {
                        TimePickerDialog(context, { _, h, m ->
                            minutes = h * 60 + m
                            NightlyReminder.update(context, enabled, minutes)
                        }, minutes / 60, minutes % 60, DateFormat.is24HourFormat(context)).show()
                    }.padding(vertical = 6.dp),
                ) {
                    Text(stringResource(R.string.set_notif_time), color = Color.White, modifier = Modifier.weight(1f))
                    val time = Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, minutes / 60)
                        set(Calendar.MINUTE, minutes % 60)
                    }.time
                    Text(java.text.DateFormat.getTimeInstance(java.text.DateFormat.SHORT).format(time), color = Cyan)
                }
            }
            LinkRow(stringResource(R.string.set_notif_test)) {
                ensureNotificationPermission()
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({ NightlyReminder.show(context) }, 3_000)
                testSent = true
            }
            if (testSent) Text(stringResource(R.string.set_notif_test_sent), color = Gray, fontSize = 12.sp)
        }

        if (!isPro && privacyRequired) {
            Section(stringResource(R.string.set_ads)) {
                LinkRow(stringResource(R.string.set_ads_privacy)) { AdsManager.showPrivacyOptions(activity) }
            }
        }

        if (testAds) {
            Section(stringResource(R.string.set_ads_debug)) {
                Text(stringResource(R.string.set_ads_test_on), color = Orange, fontSize = 12.sp)
                diagnostics.forEach { Text(it, color = Gray, fontSize = 10.sp, fontFamily = FontFamily.Monospace) }
            }
        }

        Section(stringResource(R.string.set_data)) {
            LinkRow(stringResource(R.string.set_delete), color = Color(0xFFF87171)) { confirmDelete = true }
        }

        Section(stringResource(R.string.set_about)) {
            LinkRow(stringResource(R.string.set_privacy)) {
                context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_URL)))
            }
            HorizontalDivider(color = Color.White.copy(alpha = 0.06f))
            LinkRow(stringResource(R.string.set_support)) {
                context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(SUPPORT_URL)))
            }
            HorizontalDivider(color = Color.White.copy(alpha = 0.06f))
            Row(
                modifier = Modifier.fillMaxWidth().clickable {
                    // 7 tocchi: annunci di test on/off (per verificare gli annunci senza cliccare quelli reali)
                    versionTaps++
                    if (versionTaps >= 7) {
                        versionTaps = 0
                        AdsManager.toggleTestAds()
                    }
                }.padding(vertical = 8.dp),
            ) {
                Text(stringResource(R.string.set_version), color = Color.White, modifier = Modifier.weight(1f))
                Text("${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})", color = Gray)
            }
        }
    }

    if (confirmDelete) {
        AlertDialog(
            onDismissRequest = { confirmDelete = false },
            title = { Text(stringResource(R.string.set_delete_confirm)) },
            text = { Text(stringResource(R.string.set_delete_msg)) },
            confirmButton = {
                TextButton(onClick = {
                    Store.deleteAll()
                    confirmDelete = false
                }) { Text(stringResource(R.string.set_delete), color = Color(0xFFF87171)) }
            },
            dismissButton = { TextButton(onClick = { confirmDelete = false }) { Text(stringResource(R.string.set_cancel)) } },
        )
    }
}

@Composable
private fun Section(title: String, content: @Composable ColumnScope.() -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(title.uppercase(), color = Gray, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(start = 4.dp))
        Column(
            Modifier
                .fillMaxWidth()
                .background(CardColor, RoundedCornerShape(16.dp))
                .padding(horizontal = 16.dp, vertical = 10.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
            content = content,
        )
    }
}

@Composable
private fun LinkRow(text: String, color: Color = Cyan, onClick: () -> Unit) {
    Text(text, color = color, modifier = Modifier.fillMaxWidth().clickable(onClick = onClick).padding(vertical = 8.dp))
}
