# 🚀 Guida Completa per la Pubblicazione su App Store, Monetizzazione Ibrida (Unity Ads + StoreKit 2)

Questa guida ti accompagna passo-passo nella pubblicazione dell'app **LifeSync AI** su **App Store** con una strategia di **Monetizzazione Ibrida**:
1. **Utenti Free**: Video Ads Rewarded ed Interstitial tramite **Unity Ads (Cloud Unity Organization Game ID: `687287710`)**.
2. **Utenti Pro**: Abbonamento Auto-Rinnovabile senza annunci (**€4,99/mese con 7 Giorni di Prova Gratis**).

---

## 🎬 PARTE 1: Configurazione Unity Ads (Cloud Unity)

1. Accedi al tuo dashboard **Unity Cloud Monetization**:
   [cloud.unity.com/monetization-v2](https://cloud.unity.com/organizations/6872877102477/monetization-v2/apps)
2. **Game ID iOS**: Registra la tua app `LifeSync AI iOS` (Game ID generato: `687287710`).
3. **Placements da abilitare**:
   - `Rewarded_iOS`: Video spot per consentire agli utenti Free di sbloccare la sintesi AI giornaliera.
   - `Interstitial_iOS`: Spot video prima dell'esportazione del backup JSON.
   - `Banner_iOS`: Banner pubblicitario opzionale in basso.

---

## 💰 PARTE 2: Configurazione Abbonamento StoreKit 2 (7 Giorni Gratis)

1. Accedi a [App Store Connect](https://appstoreconnect.apple.com) -> **Le mie App**.
2. Vai nella sezione **Abbonamenti**:
   - Gruppo di Abbonamenti: `LifeSync Pro`.
   - **ID Prodotto**: `com.lifesync.ai.pro.monthly`
   - **Prezzo**: €4,99 / mese.
   - **Offerta Introduttiva**: **7 Giorni di Prova Gratuita** (Free Trial).

---

## 📱 PARTE 3: Aprire il Progetto su Xcode e Associare i File

1. Apri Xcode su Mac ed importa la cartella `ios/LifeSyncAI/`:
   - `UnityAdsManager.swift` (Manager SDK Unity Ads)
   - `SubscriptionManager.swift` (StoreKit 2)
   - `PaywallView.swift` (Paywall Pro)
   - `LocalizationManager.swift` (Multi-lingua IT, EN, ES, FR)
   - `DeviceActivityManager.swift` (Screen Time & Messaging)
   - `LocationManager.swift`
   - `MotionTracker.swift`
   - `DailyLogAggregator.swift`
   - `AISummarizerService.swift`
   - `ContentView.swift`

2. Aggiungi la dipendenza **Unity Ads iOS SDK** in Xcode:
   - In Xcode: **File** -> **Add Package Dependencies** -> URL: `https://github.com/Unity-Technologies/unity-ads-ios-advertiser-sdk.git`

---

## 🌐 PARTE 4: Salvare e Caricare su GitHub

Dal terminale nella cartella del progetto:

```bash
# Salva le modifiche in Git
git add .
git commit -m "Integrazione Unity Ads SDK e monetizzazione abbonamento Pro"

# Carica su GitHub
git remote add origin https://github.com/IL_TUO_USERNAME/LifeSync-AI.git
git branch -M main
git push -u origin main
```
