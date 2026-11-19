package com.konechoco.lifesyncai.ads

import android.app.Activity
import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.core.content.edit
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import com.konechoco.lifesyncai.billing.BillingManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.lang.ref.WeakReference
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Monetizzazione con Google AdMob: video all'apertura (app open), banner, interstitial e video con premio.
 * Ordine: consenso GDPR (UMP) → avvio SDK → video all'apertura. Con LifeSync Pro nessun annuncio.
 */
object AdsManager {
    private const val TAG = "LifeSyncAds"
    private const val PREFS = "ads"
    private const val KEY_TEST = "testMode"

    private data class Units(val banner: String, val interstitial: String, val rewarded: String, val appOpen: String)

    /** Unità reali dell'app AdMob "LifeSync AI Android" (ca-app-pub-1151868778464777~2984502279). */
    private val REAL = Units(
        banner = "ca-app-pub-1151868778464777/4896349747",
        interstitial = "ca-app-pub-1151868778464777/2709170105",
        rewarded = "ca-app-pub-1151868778464777/7216884612",
        appOpen = "ca-app-pub-1151868778464777/2046825126",
    )

    /** Unità di test ufficiali Google (si attivano con 7 tocchi sulla versione nelle Impostazioni). */
    private val TEST = Units(
        banner = "ca-app-pub-3940256099942544/9214589741",
        interstitial = "ca-app-pub-3940256099942544/1033173712",
        rewarded = "ca-app-pub-3940256099942544/5224354917",
        appOpen = "ca-app-pub-3940256099942544/9257395921",
    )

    // Frequenze (stesse regole delle altre app Ikonet): mai annunci a raffica.
    private const val INTERSTITIAL_EVERY_N_ACTIONS = 2
    private const val MIN_GAP_FULLSCREEN_MS = 45_000L
    private const val APP_OPEN_MIN_BACKGROUND_MS = 20_000L
    private const val APP_OPEN_LOAD_TIMEOUT_MS = 8_000L

    private lateinit var appContext: Context
    private var activityRef = WeakReference<Activity>(null)

    private val _adsReady = MutableStateFlow(false)
    val adsReady: StateFlow<Boolean> = _adsReady.asStateFlow()

    private val _privacyOptionsRequired = MutableStateFlow(false)
    val privacyOptionsRequired: StateFlow<Boolean> = _privacyOptionsRequired.asStateFlow()

    private val _startupDone = MutableStateFlow(false)
    /** Diventa true quando consenso e video all'apertura sono finiti: poi si possono chiedere i permessi. */
    val startupDone: StateFlow<Boolean> = _startupDone.asStateFlow()

    private val _testAds = MutableStateFlow(false)
    val testAds: StateFlow<Boolean> = _testAds.asStateFlow()

    private val _diagnostics = MutableStateFlow<List<String>>(emptyList())
    val diagnostics: StateFlow<List<String>> = _diagnostics.asStateFlow()

    private var started = false
    private var appOpenAd: AppOpenAd? = null
    private var appOpenLoading = false
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private var showingFullscreen = false
    private var lastFullscreenAt = 0L
    private var actionCount = 0
    private var backgroundedAt = 0L

    private val units get() = if (_testAds.value) TEST else REAL
    val bannerUnitId: String get() = units.banner
    private val isPro get() = BillingManager.isPro.value

    fun init(context: Context) {
        appContext = context.applicationContext
        _testAds.value = appContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY_TEST, false)
        ProcessLifecycleOwner.get().lifecycle.addObserver(object : DefaultLifecycleObserver {
            override fun onStop(owner: LifecycleOwner) {
                backgroundedAt = SystemClock.elapsedRealtime()
            }

            override fun onStart(owner: LifecycleOwner) {
                val since = backgroundedAt
                backgroundedAt = 0
                if (since > 0 && SystemClock.elapsedRealtime() - since >= APP_OPEN_MIN_BACKGROUND_MS) {
                    showAppOpen()
                }
            }
        })
    }

    fun attach(activity: Activity) {
        activityRef = WeakReference(activity)
    }

    // ---------- Avvio: consenso GDPR → SDK → video all'apertura ----------

    /** Da chiamare quando finisce il video introduttivo. */
    fun start(activity: Activity) {
        attach(activity)
        if (started) return
        started = true
        // Rete di sicurezza: dopo 15 s l'app prosegue comunque (permessi, schermate) anche senza risposta.
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({ _startupDone.value = true }, 15_000)

        val consent = UserMessagingPlatform.getConsentInformation(activity)
        consent.requestConsentInfoUpdate(
            activity,
            ConsentRequestParameters.Builder().build(),
            {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { formError ->
                    if (formError != null) log("modulo consenso: ${formError.message}")
                    afterConsent(consent)
                }
            },
            { error ->
                log("richiesta consenso fallita: ${error.message}")
                afterConsent(consent)
            },
        )
    }

    private fun afterConsent(consent: ConsentInformation) {
        _privacyOptionsRequired.value =
            consent.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
        if (!consent.canRequestAds()) {
            log("annunci non consentiti dal consenso (canRequestAds = false)")
            _startupDone.value = true
            return
        }
        MobileAds.initialize(appContext) {}
        _adsReady.value = true
        log("SDK AdMob avviato" + if (_testAds.value) " (annunci di test)" else "")
        loadInterstitial()
        loadRewarded()
        showAppOpenAtLaunch()
    }

    fun showPrivacyOptions(activity: Activity) {
        UserMessagingPlatform.showPrivacyOptionsForm(activity) { error ->
            if (error != null) log("modulo privacy: ${error.message}")
            val consent = UserMessagingPlatform.getConsentInformation(activity)
            _privacyOptionsRequired.value =
                consent.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
        }
    }

    // ---------- Video all'apertura ----------

    /** All'avvio aspetta al massimo 8 secondi: meglio perdere un annuncio che bloccare l'utente. */
    private fun showAppOpenAtLaunch() {
        if (isPro) {
            _startupDone.value = true
            return
        }
        val requestedAt = SystemClock.elapsedRealtime()
        loadAppOpen { loaded ->
            val inTime = SystemClock.elapsedRealtime() - requestedAt <= APP_OPEN_LOAD_TIMEOUT_MS
            if (loaded && inTime) showAppOpen(onDone = { _startupDone.value = true }) else _startupDone.value = true
        }
    }

    private fun loadAppOpen(onResult: (Boolean) -> Unit) {
        if (appOpenAd != null) return onResult(true)
        if (appOpenLoading) return onResult(false)
        appOpenLoading = true
        AppOpenAd.load(appContext, units.appOpen, AdRequest.Builder().build(), object : AppOpenAd.AppOpenAdLoadCallback() {
            override fun onAdLoaded(ad: AppOpenAd) {
                appOpenLoading = false
                appOpenAd = ad
                log("app open caricato")
                onResult(true)
            }

            override fun onAdFailedToLoad(error: LoadAdError) {
                appOpenLoading = false
                log("app open non disponibile: ${error.message}")
                onResult(false)
            }
        })
    }

    private fun showAppOpen(onDone: () -> Unit = {}) {
        val activity = activityRef.get()
        val ad = appOpenAd
        if (!_adsReady.value || isPro || showingFullscreen || activity == null) return onDone()
        if (ad == null) {
            loadAppOpen { }
            return onDone()
        }
        appOpenAd = null
        showingFullscreen = true
        ad.fullScreenContentCallback = fullscreenCallback {
            onDone()
            loadAppOpen { }
        }
        ad.show(activity)
        lastFullscreenAt = SystemClock.elapsedRealtime()
    }

    // ---------- Interstitial ogni 2 azioni (cambio scheda) ----------

    fun registerAction(activity: Activity) {
        attach(activity)
        if (!_adsReady.value || isPro) return
        actionCount++
        if (actionCount % INTERSTITIAL_EVERY_N_ACTIONS != 0) return
        if (SystemClock.elapsedRealtime() - lastFullscreenAt < MIN_GAP_FULLSCREEN_MS || showingFullscreen) return
        val ad = interstitialAd ?: return loadInterstitial()
        interstitialAd = null
        showingFullscreen = true
        ad.fullScreenContentCallback = fullscreenCallback { loadInterstitial() }
        ad.show(activity)
        lastFullscreenAt = SystemClock.elapsedRealtime()
    }

    private fun loadInterstitial() {
        if (!_adsReady.value || isPro || interstitialAd != null) return
        InterstitialAd.load(appContext, units.interstitial, AdRequest.Builder().build(), object : InterstitialAdLoadCallback() {
            override fun onAdLoaded(ad: InterstitialAd) {
                interstitialAd = ad
                log("interstitial caricato")
            }

            override fun onAdFailedToLoad(error: LoadAdError) {
                log("interstitial non disponibile: ${error.message}")
            }
        })
    }

    // ---------- Video con premio (sblocca il riepilogo) ----------

    /**
     * `true` se l'utente ha guardato il video fino in fondo, oppure se non c'è nessun video disponibile
     * (in quel caso la funzione resta utilizzabile invece di bloccare l'utente).
     */
    fun showRewarded(activity: Activity, onResult: (Boolean) -> Unit) {
        attach(activity)
        if (isPro) return onResult(true)
        val ad = rewardedAd
        if (!_adsReady.value || ad == null) {
            log("video con premio non pronto: funzione sbloccata senza annuncio")
            loadRewarded()
            return onResult(true)
        }
        rewardedAd = null
        var earned = false
        showingFullscreen = true
        ad.fullScreenContentCallback = fullscreenCallback {
            onResult(earned)
            loadRewarded()
        }
        ad.show(activity) { earned = true }
        lastFullscreenAt = SystemClock.elapsedRealtime()
    }

    private fun loadRewarded() {
        if (!_adsReady.value || isPro || rewardedAd != null) return
        RewardedAd.load(appContext, units.rewarded, AdRequest.Builder().build(), object : RewardedAdLoadCallback() {
            override fun onAdLoaded(ad: RewardedAd) {
                rewardedAd = ad
                log("video con premio caricato")
            }

            override fun onAdFailedToLoad(error: LoadAdError) {
                log("video con premio non disponibile: ${error.message}")
            }
        })
    }

    private fun fullscreenCallback(onFinished: () -> Unit) = object : FullScreenContentCallback() {
        override fun onAdDismissedFullScreenContent() {
            showingFullscreen = false
            lastFullscreenAt = SystemClock.elapsedRealtime()
            onFinished()
        }

        override fun onAdFailedToShowFullScreenContent(error: AdError) {
            showingFullscreen = false
            log("annuncio non mostrato: ${error.message}")
            onFinished()
        }
    }

    // ---------- Annunci di test ----------

    fun toggleTestAds() {
        _testAds.value = !_testAds.value
        appContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit { putBoolean(KEY_TEST, _testAds.value) }
        appOpenAd = null
        interstitialAd = null
        rewardedAd = null
        log(if (_testAds.value) "annunci di test ATTIVI" else "annunci reali")
        loadInterstitial()
        loadRewarded()
    }

    private fun log(message: String) {
        val time = SimpleDateFormat("HH:mm:ss", Locale.US).format(Date())
        _diagnostics.value = (listOf("$time  $message") + _diagnostics.value).take(40)
        Log.d(TAG, message)
    }
}
