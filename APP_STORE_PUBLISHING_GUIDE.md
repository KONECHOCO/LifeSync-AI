# 🚀 Guida Completa per la Pubblicazione su App Store e Monetizzazione (LifeSync AI)

Questa guida ti accompagna passo-passo nella pubblicazione dell'app **LifeSync AI** su **App Store** con la monetizzazione ad **Abbonamento Auto-Rinnovabile (€4,99/mese con 7 Giorni di Prova Gratuita)**.

---

## 📋 REQUISITI PRELIMINARI

1. **Account Apple Developer Program**:
   Occorre registrarsi su [developer.apple.com](https://developer.apple.com) ($99/anno).
2. **Mac con Xcode (versione 15.0 o successiva)**:
   Scaricabile gratuitamente dal Mac App Store.
3. **Repository GitHub**:
   Salva e gestisci le versioni del codice sorgente su GitHub.

---

## 💰 PASSAGGIO 1: Configurazione Monetizzazione su App Store Connect

1. Accedi a [App Store Connect](https://appstoreconnect.apple.com) -> **Le mie App** -> **Nuova App**.
2. **Identificatore App (Bundle ID)**: Crea un Bundle ID univoco (es. `com.lifesync.ai`).
3. Vai nella sezione **Abbonamenti**:
   - Clicca su **Crea Gruppo di Abbonamenti** (Nome: `LifeSync Pro`).
   - Aggiungi un **Prodotto Abbonamento Auto-Rinnovabile**:
     - **ID Prodotto**: `com.lifesync.ai.pro.monthly`
     - **Prezzo**: €4,99 / mese (o $4.99).
   - **Offerta Introduttiva (7 Giorni di Prova Gratis)**:
     - Clicca su **Offerte Introduttive** -> Seleziona **Prova Gratuita (Free Trial)**.
     - Durata: **1 Settimana (7 giorni)**.

> ℹ️ *Gli utenti scaricheranno l'app, attiveranno la prova di 7 giorni a costo €0.00, e solo all'8° giorno Apple addebiterà automaticamente €4,99/mese.*

---

## 📱 PASSAGGIO 2: Aprire il Progetto su Xcode e Associare i File

1. Apri Xcode su Mac e crea un nuovo **iOS App Project** denominato `LifeSyncAI` (Bundle ID: `com.lifesync.ai`).
2. Trascina all'interno del progetto Xcode tutti i file contenuti nella cartella `ios/LifeSyncAI/`:
   - `LifeSyncApp.swift`
   - `SubscriptionManager.swift` (StoreKit 2)
   - `PaywallView.swift` (Paywall 7 Giorni Gratis)
   - `LocalizationManager.swift` (Multi-lingua IT, EN, ES, FR)
   - `DeviceActivityManager.swift` (Screen Time & Messaging)
   - `LocationManager.swift`
   - `MotionTracker.swift`
   - `DailyLogAggregator.swift`
   - `AISummarizerService.swift`
   - `ContentView.swift`

3. In **Signing & Capabilities** su Xcode:
   - Aggiungi **In-App Purchase**.
   - Aggiungi **Background Modes** (Location updates, Background processing).
   - Aggiungi **Family Controls (DeviceActivity)** per il tracciamento del tempo schermo delle app di messaggistica.

---

## 🌐 PASSAGGIO 3: Caricare il Progetto su GitHub

Per salvare il tuo progetto su GitHub dal terminale:

```bash
# 1. Inizializza Git (se non già fatto)
git init

# 2. Aggiungi tutti i file ed effettua il commit
git add .
git commit -m "Versione 1.0.0: LifeSync AI con StoreKit 2 (7 giorni prova gratis, €4,99/mese) e multi-lingua"

# 3. Collega il tuo repository remoto GitHub e carica il codice
git remote add origin https://github.com/IL_TUO_USERNAME/LifeSync-AI.git
git branch -M main
git push -u origin main
```

---

## 📝 PASSAGGIO 4: Compilazione & Invio all'App Review

1. Su Xcode, seleziona la destinazione **Any iOS Device (arm64)**.
2. Vai nel menu **Product** -> **Archive**.
3. Al termine dell'Archiviazione, clicca su **Distribute App** -> **TestFlight & App Store**.
4. Su App Store Connect:
   - Compila la descrizione dell'app, gli screenshot dell'iPhone e l'URL della Privacy Policy.
   - Associa l'abbonamento `com.lifesync.ai.pro.monthly` alla scheda della versione.
   - Clicca su **Invia per la Revisione (App Review)**.
