package com.konechoco.lifesyncai.ui

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.TableChart
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material.icons.outlined.WorkspacePremium
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.konechoco.lifesyncai.R
import com.konechoco.lifesyncai.billing.BillingManager

const val PRIVACY_URL = "https://github.com/KONECHOCO/LifeSync-AI/blob/main/PRIVACY.md"
const val SUPPORT_URL = "https://github.com/KONECHOCO/LifeSync-AI"

@Composable
fun ProFeatures() {
    Card {
        FeatureRow(Icons.Filled.Block, Pink, stringResource(R.string.pw_f4_t), stringResource(R.string.pw_f4_s))
        FeatureRow(Icons.Filled.AutoAwesome, Yellow, stringResource(R.string.pw_f1_t), stringResource(R.string.pw_f1_s))
        FeatureRow(Icons.Filled.TableChart, Cyan, stringResource(R.string.pw_f2_t), stringResource(R.string.pw_f2_s))
        FeatureRow(Icons.Filled.Lock, Green, stringResource(R.string.pw_f3_t), stringResource(R.string.pw_f3_s))
    }
}

@Composable
fun BuyButton(activity: Activity) {
    val price by BillingManager.price.collectAsState()
    val unavailable = stringResource(R.string.pw_unavailable)
    val label = price?.let { stringResource(R.string.pw_cta_price, it) } ?: stringResource(R.string.pw_cta)
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(AccentGradient)
            .clickable { BillingManager.purchase(activity, unavailable) }
            .padding(vertical = 16.dp),
    ) {
        Text(label, color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 16.sp)
    }
}

@Composable
private fun PurchaseFeedback() {
    val message by BillingManager.message.collectAsState()
    val pending by BillingManager.pending.collectAsState()
    if (pending) Text(stringResource(R.string.pw_purchase_pending), color = Orange, fontSize = 12.sp, textAlign = TextAlign.Center)
    message?.let { text ->
        AlertDialog(
            onDismissRequest = { BillingManager.clearMessage() },
            confirmButton = { TextButton(onClick = { BillingManager.clearMessage() }) { Text(stringResource(R.string.pw_ok)) } },
            title = { Text(stringResource(R.string.pw_error_title)) },
            text = { Text(text) },
        )
    }
}

@Composable
fun ProScreen(activity: Activity) {
    val isPro by BillingManager.isPro.collectAsState()
    val context = LocalContext.current
    Column(
        Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Card {
            Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Icon(if (isPro) Icons.Filled.WorkspacePremium else Icons.Outlined.WorkspacePremium, null, tint = Yellow, modifier = Modifier.size(48.dp))
                Text("LifeSync AI Pro", color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                Text(
                    stringResource(if (isPro) R.string.pro_status_active else R.string.pro_status_free),
                    color = if (isPro) Green else Gray, fontWeight = FontWeight.SemiBold,
                )
                Text(
                    stringResource(if (isPro) R.string.pro_active_desc else R.string.pro_free_desc),
                    color = Gray, fontSize = 12.sp, textAlign = TextAlign.Center,
                )
            }
        }
        ProFeatures()
        if (!isPro) {
            BuyButton(activity)
            Text(stringResource(R.string.pw_price_note), color = Gray, fontSize = 11.sp, textAlign = TextAlign.Center)
        }
        PurchaseFeedback()
        TextButton(onClick = { BillingManager.refreshPurchases() }) {
            Text(stringResource(R.string.pw_restore), color = Cyan)
        }
        TextButton(onClick = { context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_URL))) }) {
            Text(stringResource(R.string.pw_privacy_link), color = Cyan, fontSize = 12.sp)
        }
    }
}

/** Paywall a schermo intero: LifeSync AI Pro con acquisto unico. */
@Composable
fun PaywallDialog(activity: Activity, onDismiss: () -> Unit) {
    val isPro by BillingManager.isPro.collectAsState()
    LaunchedEffect(isPro) { if (isPro) onDismiss() }
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        Column(
            Modifier
                .fillMaxSize()
                .background(AppBackground)
                .statusBarsPadding()
                .navigationBarsPadding()
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            Row(Modifier.fillMaxWidth()) {
                Spacer(Modifier.weight(1f))
                IconButton(onClick = onDismiss) { Icon(Icons.Filled.Close, contentDescription = null, tint = Gray) }
            }
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(80.dp).clip(RoundedCornerShape(24.dp)).background(AccentGradient),
            ) {
                Icon(Icons.Filled.Psychology, null, tint = Color.White, modifier = Modifier.size(44.dp))
            }
            Text("LifeSync AI Pro", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Black)
            Text(stringResource(R.string.pw_subtitle), color = Gray, fontSize = 14.sp, textAlign = TextAlign.Center)
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .background(Yellow.copy(alpha = 0.15f), RoundedCornerShape(20.dp))
                    .border(1.dp, Yellow.copy(alpha = 0.4f), RoundedCornerShape(20.dp))
                    .padding(horizontal = 16.dp, vertical = 8.dp),
            ) {
                Icon(Icons.Filled.Verified, null, tint = Yellow, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(8.dp))
                Text(stringResource(R.string.pw_onetime_badge), color = Yellow, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }
            ProFeatures()
            BuyButton(activity)
            Text(stringResource(R.string.pw_price_note), color = Gray, fontSize = 11.sp, textAlign = TextAlign.Center)
            PurchaseFeedback()
            TextButton(onClick = { BillingManager.refreshPurchases() }) {
                Text(stringResource(R.string.pw_restore), color = Cyan)
            }
        }
    }
}
