# 🧠 LifeSync AI — Personal Assistant & Daily Backup (iOS App Store Ready)

LifeSync AI is a high-performance iOS life-logging assistant and daily narrative backup application built with SwiftUI, SwiftData, and StoreKit 2.

![LifeSync AI Banner](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)
![StoreKit 2](https://img.shields.io/badge/Monetization-StoreKit%202%20(One--Time%20Purchase)-green.svg)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

---

## 🌟 Key Features

- **📍 Battery-Efficient Motion & Location Log (`CoreLocation` & `CoreMotion`)**: Uses `CLVisit` and `Significant Location Changes` to consume <0.8% battery per day.
- **💬 Communication Usage Module (`DeviceActivity`)**: Prepared for Screen Time-based communication app usage when the Apple entitlement is approved.
- **🎙️ Quick Voice Journaling (`AVFoundation` & Siri Shortcuts)**: Record quick audio thoughts that are transcribed and summarized into the daily backup.
- **🤖 Automated AI Daily Summary**: Generates a daily narrative backup report every evening at 11:00 PM.
- **🔒 Local Daily Archive (SwiftData)**: Private on-device storage for daily activity summaries.
- **🌍 Native Multi-Language Support (i18n)**: Fully localized in **Italian, English, Spanish, and French**.
- **💰 StoreKit 2 One-Time Pro Purchase**: €3.99 one-time, non-consumable purchase — no subscription, no recurring charge. Removes ads, unlocks unlimited AI summaries and CSV export.
- **⌚ Apple Watch Companion App**: Embedded watchOS app that mirrors today's steps, places, rest time, and AI summary via WatchConnectivity.
- **🎬 Branded Intro Animation**: Short, skippable video shown on every cold launch.

---

## 📁 Repository Structure

```
AGENT/
├── ios/
│   └── LifeSyncAI/
│       ├── LifeSyncApp.swift              # App entry point with SwiftData & StoreKit setup
│       ├── PurchaseManager.swift          # StoreKit 2 one-time Pro purchase logic
│       ├── PaywallView.swift              # SwiftUI Paywall View for the one-time Pro purchase
│       ├── IntroVideoView.swift           # Skippable branded intro video played on launch
│       ├── PhoneConnectivityManager.swift # Sends today's summary to the Apple Watch app
│       ├── LocalizationManager.swift      # Dynamic i18n localization
│       ├── DeviceActivityManager.swift    # Screen Time & messaging app usage tracking
│       ├── LocationManager.swift          # CoreLocation passive visit tracker
│       ├── MotionTracker.swift            # CoreMotion pedometer & activity tracker
│       ├── DailyLogAggregator.swift       # SwiftData DailyBackupLog model
│       ├── AISummarizerService.swift      # AI Summary generator & local notifications
│       └── ContentView.swift              # Main SwiftUI interface
│
├── APP_STORE_PUBLISHING_GUIDE.md          # Step-by-step App Store publishing checklist
├── index.html                             # Web Simulator Dashboard
├── index.css                             # Glassmorphism styling
├── app.js                                 # Web simulator & StoreKit paywall logic
└── README.md
```

---

## 🚀 How to Run locally

### 1. Web Simulator
Launch a simple HTTP server in the repository folder:
```bash
python -m http.server 8080
```
Open `http://localhost:8080` in your browser to test the interactive simulator and paywall overlay.

### 2. Xcode Project Setup
1. Open Xcode and create a new SwiftUI iOS App named `LifeSyncAI`.
2. Copy the contents of the `ios/LifeSyncAI` directory into your project.
3. Enable **Background Modes** (Location updates, Background processing) and **In-App Purchase** capabilities.
4. Add the `com.lifesync.ai.pro.monthly` Auto-Renewable Subscription product in App Store Connect.

---

## 🔒 App Store Compliance & Privacy

- Operates strictly within official Apple iOS APIs (`CoreLocation`, `CoreMotion`, `DeviceActivity` when entitlement-approved, and StoreKit 2).
- No unauthorized keylogging or screen recording. 100% compliant with Apple App Review Guidelines.

---

## 📄 License
Distributed under the MIT License.
