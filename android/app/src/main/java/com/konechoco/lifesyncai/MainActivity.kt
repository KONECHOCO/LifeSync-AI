package com.konechoco.lifesyncai

import android.net.Uri
import android.os.Bundle
import android.widget.VideoView
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.konechoco.lifesyncai.ads.AdsManager
import com.konechoco.lifesyncai.ads.BannerAd
import com.konechoco.lifesyncai.billing.BillingManager
import com.konechoco.lifesyncai.ui.AppBackground
import com.konechoco.lifesyncai.ui.Cyan
import com.konechoco.lifesyncai.ui.Gray
import com.konechoco.lifesyncai.ui.HistoryScreen
import com.konechoco.lifesyncai.ui.LifeSyncTheme
import com.konechoco.lifesyncai.ui.ProScreen
import com.konechoco.lifesyncai.ui.SettingsScreen
import com.konechoco.lifesyncai.ui.StatsScreen
import com.konechoco.lifesyncai.ui.TodayScreen
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Tema sempre scuro: icone chiare su barra di stato e di navigazione
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
        )
        super.onCreate(savedInstanceState)
        AdsManager.attach(this)
        setContent {
            LifeSyncTheme {
                AppRoot(this)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        AdsManager.attach(this)
        BillingManager.refreshPurchases()
    }
}

@Composable
private fun AppRoot(activity: MainActivity) {
    var showIntro by rememberSaveable { mutableStateOf(true) }
    AnimatedContent(
        targetState = showIntro,
        transitionSpec = { fadeIn() togetherWith fadeOut() },
        label = "intro",
    ) { intro ->
        if (intro) {
            IntroVideo(onFinished = {
                if (showIntro) {
                    showIntro = false
                    AdsManager.start(activity)
                }
            })
        } else {
            MainTabs(activity)
        }
    }
}

/** Video di apertura (3 s, senza audio, saltabile con un tocco). */
@Composable
private fun IntroVideo(onFinished: () -> Unit) {
    var finished by remember { mutableStateOf(false) }
    val finish = {
        if (!finished) {
            finished = true
            onFinished()
        }
    }
    LaunchedEffect(Unit) {
        // Rete di sicurezza: l'utente non resta mai bloccato sull'intro
        delay(6_000)
        finish()
    }
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppBackground)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { finish() },
    ) {
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { context ->
                VideoView(context).apply {
                    setVideoURI(Uri.parse("android.resource://${context.packageName}/${R.raw.intro}"))
                    setOnPreparedListener { player ->
                        player.setVolume(0f, 0f)
                        start()
                    }
                    setOnCompletionListener { finish() }
                    setOnErrorListener { _, _, _ -> finish(); true }
                }
            },
        )
        Text(
            text = stringResource(R.string.intro_skip),
            color = Color.White.copy(alpha = 0.85f),
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .statusBarsPadding()
                .padding(16.dp)
                .background(Color.Black.copy(alpha = 0.35f), RoundedCornerShape(50))
                .clickable { finish() }
                .padding(horizontal = 14.dp, vertical = 8.dp),
        )
    }
}

@Composable
private fun MainTabs(activity: MainActivity) {
    var tab by rememberSaveable { mutableIntStateOf(0) }
    val isPro by BillingManager.isPro.collectAsState()
    val adsReady by AdsManager.adsReady.collectAsState()
    val testAds by AdsManager.testAds.collectAsState()

    val tabs = listOf(
        Triple(R.string.tab_today, Icons.Filled.Home, 0),
        Triple(R.string.tab_history, Icons.Filled.History, 1),
        Triple(R.string.tab_stats, Icons.Filled.BarChart, 2),
        Triple(R.string.tab_pro, Icons.Filled.WorkspacePremium, 3),
        Triple(R.string.tab_settings, Icons.Filled.Settings, 4),
    )

    Scaffold(
        containerColor = AppBackground,
        bottomBar = {
            Column {
                if (adsReady && !isPro) {
                    // key: con gli annunci di test il banner viene ricreato con la nuova unità
                    androidx.compose.runtime.key(testAds) {
                        BannerAd(unitId = AdsManager.bannerUnitId)
                    }
                }
                NavigationBar(containerColor = Color(0xFF0E1320)) {
                    tabs.forEach { (label, icon, index) ->
                        NavigationBarItem(
                            selected = tab == index,
                            onClick = {
                                if (tab != index) {
                                    tab = index
                                    AdsManager.registerAction(activity)
                                }
                            },
                            icon = { Icon(icon, contentDescription = null) },
                            label = { Text(stringResource(label), fontSize = 10.sp, maxLines = 1) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Cyan,
                                selectedTextColor = Cyan,
                                unselectedIconColor = Gray,
                                unselectedTextColor = Gray,
                                indicatorColor = Cyan.copy(alpha = 0.15f),
                            ),
                        )
                    }
                }
            }
        },
    ) { padding ->
        Box(Modifier.padding(padding)) {
            when (tab) {
                0 -> TodayScreen(activity)
                1 -> HistoryScreen()
                2 -> StatsScreen()
                3 -> ProScreen(activity)
                else -> SettingsScreen(activity)
            }
        }
    }
}
