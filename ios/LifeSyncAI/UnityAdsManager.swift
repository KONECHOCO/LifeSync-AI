import Foundation
import UIKit
import Combine
// Importa il SDK UnityAds nel tuo progetto Xcode tramite CocoaPods o Swift Package Manager:
// pod 'UnityAds'  OPPURE SPM: https://github.com/Unity-Technologies/unity-ads-ios-advertiser-sdk.git

#if canImport(UnityAds)
import UnityAds
#endif

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// Manager per l'integrazione della Monetizzazione Unity Ads (Video Rewarded, Interstitial & Banner)
final class UnityAdsManager: NSObject, ObservableObject {
    static let shared = UnityAdsManager()
    
    // Inserisci qui il tuo Game ID di Unity Ads dal dashboard cloud.unity.com
    static let unityGameID = "687287710" // ID di test configurato nel dashboard Unity
    static let testMode = false
    
    // Placement IDs di Unity Ads
    static let rewardedPlacementID = "Rewarded_iOS"
    static let interstitialPlacementID = "Interstitial_iOS"
    static let bannerPlacementID = "Banner_iOS"
    
    @Published var isSdkInitialized: Bool = false
    @Published var isRewardedAdReady: Bool = false
    @Published var isInterstitialReady: Bool = false
    @Published var adRewardEarned: Bool = false
    
    private var completionHandler: ((Bool) -> Void)?
    
    override init() {
        super.init()
        initializeUnityAds()
    }
    
    /// Inizializza il framework Unity Ads
    func initializeUnityAds() {
        #if canImport(UnityAds)
        requestTrackingAuthorizationIfNeeded {
            UnityAds.initialize(UnityAdsManager.unityGameID, testMode: UnityAdsManager.testMode, initializationDelegate: self)
        }
        #else
        print("SDK UnityAds in modalita simulata. Il workflow Codemagic installa il pod UnityAds per la build di produzione.")
        self.isSdkInitialized = true
        self.isRewardedAdReady = true
        #endif
    }

    private func requestTrackingAuthorizationIfNeeded(completion: @escaping () -> Void) {
        #if canImport(AppTrackingTransparency)
        guard #available(iOS 14, *) else {
            completion()
            return
        }

        ATTrackingManager.requestTrackingAuthorization { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
        #else
        completion()
        #endif
    }
    
    /// Mostra un Video Rewarded Unity Ads per sbloccare il report AI senza abbonamento
    func showRewardedAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        self.completionHandler = completion
        
        #if canImport(UnityAds)
        guard isRewardedAdReady else {
            print("⚠️ Unity Ads Rewarded non ancora pronto.")
            UnityAds.load(UnityAdsManager.rewardedPlacementID, loadDelegate: self)
            completion(false)
            return
        }
        isRewardedAdReady = false
        UnityAds.show(viewController, placementId: UnityAdsManager.rewardedPlacementID, showDelegate: self)
        #else
        // Simulazione locale per testing
        print("Unity Ads Rewarded riprodotto con successo.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.adRewardEarned = true
            completion(true)
        }
        #endif
    }
    
    /// Mostra un Ad Interstitial prima dell'esportazione del backup
    func showInterstitialAd(from viewController: UIViewController) {
        #if canImport(UnityAds)
        if isInterstitialReady {
            isInterstitialReady = false
            UnityAds.show(viewController, placementId: UnityAdsManager.interstitialPlacementID, showDelegate: self)
        } else {
            UnityAds.load(UnityAdsManager.interstitialPlacementID, loadDelegate: self)
        }
        #else
        print("Unity Ads Interstitial mostrato.")
        #endif
    }
}

// MARK: - Delegate Callbacks di Unity Ads
#if canImport(UnityAds)
extension UnityAdsManager: UnityAdsInitializationDelegate, UnityAdsShowDelegate, UnityAdsLoadDelegate {
    
    func initializationComplete() {
        print("✅ Unity Ads SDK Inizializzato con successo!")
        DispatchQueue.main.async {
            self.isSdkInitialized = true
        }
        UnityAds.load(UnityAdsManager.rewardedPlacementID, loadDelegate: self)
        UnityAds.load(UnityAdsManager.interstitialPlacementID, loadDelegate: self)
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        print("⚠️ Errore Inizializzazione Unity Ads: \(message)")
    }
    
    func unityAdsAdLoaded(_ placementId: String) {
        print("📺 Unity Ad caricato per placement: \(placementId)")
        DispatchQueue.main.async {
            if placementId == UnityAdsManager.rewardedPlacementID {
                self.isRewardedAdReady = true
            } else if placementId == UnityAdsManager.interstitialPlacementID {
                self.isInterstitialReady = true
            }
        }
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        print("⚠️ Unity Ad errore caricamento [\(placementId)]: \(message)")
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinishState state: UnityAdsShowCompletionState) {
        if state == .completed {
            print("🎁 Utente ha guardato tutto il video Unity Ads! Ricompensa concessa.")
            DispatchQueue.main.async {
                self.completionHandler?(true)
            }
        } else {
            completionHandler?(false)
        }
        UnityAds.load(placementId, loadDelegate: self)
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        print("⚠️ Unity Ads Show Errore: \(message)")
        completionHandler?(false)
    }
    
    func unityAdsShowStart(_ placementId: String) {}
    func unityAdsShowClick(_ placementId: String) {}
}
#endif
