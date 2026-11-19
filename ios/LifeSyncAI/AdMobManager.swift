import Foundation
import SwiftUI
import UIKit
import Combine
import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

/// Monetizzazione con Google AdMob: video all'apertura (app open), banner, interstitial e video con premio.
/// Consenso: prima il messaggio GDPR (UMP), poi la richiesta di tracciamento (ATT, attesa massima 10 s).
/// Con LifeSync Pro non viene mostrato nessun annuncio.
@MainActor
final class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()

    private struct UnitIDs {
        let banner: String
        let interstitial: String
        let rewarded: String
        let appOpen: String
    }

    /// Unità reali dell'app iOS "LifeSync AI" (ca-app-pub-1151868778464777~9741482318).
    private static let realIDs = UnitIDs(
        banner: "ca-app-pub-1151868778464777/2932531385",
        interstitial: "ca-app-pub-1151868778464777/9549910620",
        rewarded: "ca-app-pub-1151868778464777/8236828954",
        appOpen: "ca-app-pub-1151868778464777/5223652801"
    )

    /// Unità di test ufficiali Google: si attivano solo con il trucco dei 7 tocchi nelle Impostazioni.
    private static let testIDs = UnitIDs(
        banner: "ca-app-pub-3940256099942544/2435281174",
        interstitial: "ca-app-pub-3940256099942544/4411468910",
        rewarded: "ca-app-pub-3940256099942544/1712485313",
        appOpen: "ca-app-pub-3940256099942544/5575463023"
    )

    static let testAdsKey = "ads.testMode"

    // Frequenze (stesse regole delle altre app Ikonet): mai annunci a raffica.
    private let interstitialEveryNActions = 2
    private let minGapBetweenFullscreen: TimeInterval = 45
    private let appOpenMinBackground: TimeInterval = 20
    private let appOpenLoadTimeout: TimeInterval = 8

    @Published private(set) var adsReady = false
    @Published private(set) var privacyOptionsRequired = false
    @Published private(set) var useTestAds: Bool = UserDefaults.standard.bool(forKey: AdMobManager.testAdsKey)
    @Published private(set) var diagnostics: [String] = []

    private var started = false
    private var appOpenAd: AppOpenAd?
    private var appOpenLoading = false
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var isShowingFullscreen = false
    private var lastFullscreenAt: Date = .distantPast
    private var actionCount = 0
    private var backgroundedAt: Date?
    private var rewardCompletion: ((Bool) -> Void)?
    private var rewardEarned = false

    private var ids: UnitIDs { useTestAds ? Self.testIDs : Self.realIDs }
    private var isPro: Bool { PurchaseManager.shared.isPro }

    var bannerUnitID: String { ids.banner }

    // MARK: - Avvio: consenso GDPR → ATT → SDK

    /// Da chiamare una sola volta, appena l'interfaccia principale è visibile.
    func start() async {
        guard !started else { return }
        started = true

        await requestConsentInfoUpdate()
        if let presenter = UIViewController.topMostViewController() {
            do {
                try await ConsentForm.loadAndPresentIfRequired(from: presenter)
                log("consenso GDPR: modulo gestito")
            } catch {
                log("consenso GDPR: \(error.localizedDescription)")
            }
        }
        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required

        await requestTrackingAuthorization()

        guard ConsentInformation.shared.canRequestAds else {
            log("annunci non consentiti dal consenso (canRequestAds = false)")
            return
        }

        MobileAds.shared.start(completionHandler: nil)
        adsReady = true
        log("SDK AdMob avviato\(useTestAds ? " (annunci di test)" : "")")

        loadInterstitial()
        loadRewarded()
    }

    private func requestConsentInfoUpdate() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters()) { [weak self] error in
                Task { @MainActor in
                    if let error {
                        self?.log("richiesta consenso fallita: \(error.localizedDescription)")
                    }
                    continuation.resume()
                }
            }
        }
    }

    /// Mostra il popup di tracciamento di iOS, aspettando al massimo 10 secondi.
    private func requestTrackingAuthorization() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        let gate = OnceGate()
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ATTrackingManager.requestTrackingAuthorization { _ in
                if gate.open() { continuation.resume() }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if gate.open() { continuation.resume() }
            }
        }
        log("ATT: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)")
    }

    /// Modulo per modificare il consenso (richiesto dal messaggio GDPR).
    func presentPrivacyOptions() {
        guard let presenter = UIViewController.topMostViewController() else { return }
        Task {
            do {
                try await ConsentForm.presentPrivacyOptionsForm(from: presenter)
            } catch {
                log("modulo privacy: \(error.localizedDescription)")
            }
            privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        }
    }

    // MARK: - Video all'apertura (app open)

    /// Video all'apertura dell'app: all'avvio aspetta al massimo pochi secondi che l'annuncio sia pronto.
    func showAppOpenAtLaunch() async {
        guard adsReady, !isPro, !isShowingFullscreen else { return }
        if appOpenAd == nil {
            await loadAppOpen(timeout: appOpenLoadTimeout)
        }
        presentAppOpen()
    }

    func appDidEnterBackground() {
        backgroundedAt = Date()
    }

    /// Al rientro dopo almeno 20 secondi in background mostra di nuovo il video all'apertura.
    func appDidBecomeActive() {
        guard let since = backgroundedAt else { return }
        backgroundedAt = nil
        guard Date().timeIntervalSince(since) >= appOpenMinBackground else { return }
        Task { await showAppOpenAtLaunch() }
    }

    /// Carica il video all'apertura e aspetta al massimo `timeout` secondi:
    /// meglio perdere un annuncio che bloccare l'utente sull'avvio.
    private func loadAppOpen(timeout: TimeInterval) async {
        if !appOpenLoading {
            appOpenLoading = true
            let unitID = ids.appOpen
            Task {
                do {
                    let ad = try await AppOpenAd.load(with: unitID, request: Request())
                    ad.fullScreenContentDelegate = self
                    self.appOpenAd = ad
                    self.log("app open caricato")
                } catch {
                    self.log("app open non disponibile: \(error.localizedDescription)")
                }
                self.appOpenLoading = false
            }
        }
        let deadline = Date().addingTimeInterval(timeout)
        while appOpenAd == nil && appOpenLoading && Date() < deadline {
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
    }

    private func presentAppOpen() {
        guard let ad = appOpenAd, let presenter = UIViewController.topMostViewController() else { return }
        appOpenAd = nil
        isShowingFullscreen = true
        ad.present(from: presenter)
        lastFullscreenAt = Date()
    }

    // MARK: - Interstitial ogni 2 azioni (es. cambio scheda)

    func registerAction() {
        guard adsReady, !isPro else { return }
        actionCount += 1
        guard actionCount % interstitialEveryNActions == 0,
              Date().timeIntervalSince(lastFullscreenAt) >= minGapBetweenFullscreen,
              !isShowingFullscreen else { return }
        guard let ad = interstitialAd, let presenter = UIViewController.topMostViewController() else {
            loadInterstitial()
            return
        }
        interstitialAd = nil
        isShowingFullscreen = true
        ad.present(from: presenter)
        lastFullscreenAt = Date()
    }

    private func loadInterstitial() {
        guard adsReady, !isPro, interstitialAd == nil else { return }
        InterstitialAd.load(with: ids.interstitial, request: Request()) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
                if let ad {
                    ad.fullScreenContentDelegate = self
                    self.interstitialAd = ad
                    self.log("interstitial caricato")
                } else {
                    self.log("interstitial non disponibile: \(error?.localizedDescription ?? "-")")
                }
            }
        }
    }

    // MARK: - Video con premio (sblocca il riepilogo giornaliero)

    /// `true` se l'utente ha guardato il video fino in fondo, oppure se non c'è nessun video disponibile
    /// (in quel caso la funzione resta utilizzabile invece di bloccare l'utente).
    func showRewarded(completion: @escaping (Bool) -> Void) {
        guard !isPro else {
            completion(true)
            return
        }
        guard adsReady, let ad = rewardedAd, let presenter = UIViewController.topMostViewController() else {
            log("video con premio non pronto: funzione sbloccata senza annuncio")
            loadRewarded()
            completion(true)
            return
        }
        rewardedAd = nil
        rewardEarned = false
        rewardCompletion = completion
        isShowingFullscreen = true
        ad.present(from: presenter) { [weak self] in
            Task { @MainActor in self?.rewardEarned = true }
        }
        lastFullscreenAt = Date()
    }

    private func loadRewarded() {
        guard adsReady, !isPro, rewardedAd == nil else { return }
        RewardedAd.load(with: ids.rewarded, request: Request()) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
                if let ad {
                    ad.fullScreenContentDelegate = self
                    self.rewardedAd = ad
                    self.log("video con premio caricato")
                } else {
                    self.log("video con premio non disponibile: \(error?.localizedDescription ?? "-")")
                }
            }
        }
    }

    // MARK: - Annunci di test (7 tocchi sulla versione nelle Impostazioni)

    func toggleTestAds() {
        useTestAds.toggle()
        UserDefaults.standard.set(useTestAds, forKey: Self.testAdsKey)
        appOpenAd = nil
        interstitialAd = nil
        rewardedAd = nil
        log(useTestAds ? "annunci di test ATTIVI" : "annunci reali")
        loadInterstitial()
        loadRewarded()
    }

    private func log(_ message: String) {
        let time = Date().formatted(date: .omitted, time: .standard)
        diagnostics.insert("\(time)  \(message)", at: 0)
        if diagnostics.count > 40 { diagnostics.removeLast() }
        print("[AdMob] \(message)")
    }
}

extension AdMobManager: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in self.fullscreenEnded(ad) }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            self.log("annuncio non mostrato: \(error.localizedDescription)")
            self.fullscreenEnded(ad)
        }
    }

    private func fullscreenEnded(_ ad: FullScreenPresentingAd) {
        isShowingFullscreen = false
        lastFullscreenAt = Date()
        if ad is RewardedAd, let completion = rewardCompletion {
            rewardCompletion = nil
            completion(rewardEarned)
            loadRewarded()
        } else if ad is InterstitialAd {
            loadInterstitial()
        }
    }
}

/// Lascia passare una sola chiamata (serve per l'attesa massima dell'ATT).
private final class OnceGate: @unchecked Sendable {
    private let lock = NSLock()
    private var opened = false

    func open() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if opened { return false }
        opened = true
        return true
    }
}

/// Banner adattivo ancorato in fondo allo schermo (nascosto per gli utenti Pro).
struct AdBannerView: UIViewRepresentable {
    let unitID: String
    let adSize: AdSize

    static func anchoredSize() -> AdSize {
        currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = unitID
        banner.rootViewController = UIViewController.topMostViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ banner: BannerView, context: Context) {
        if banner.rootViewController == nil {
            banner.rootViewController = UIViewController.topMostViewController()
        }
    }
}
