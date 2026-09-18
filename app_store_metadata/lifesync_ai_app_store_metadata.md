# LifeSync AI - App Store Metadata

## App

- Name: LifeSync AI
- Bundle ID: `com.konechoco.lifesyncai`
- SKU: `lifesync-ai-ios`
- Category: Productivity
- Age rating: 4+
- Version: `1.0`
- In-app purchase: `com.lifesync.ai.pro.monthly`
- Subscription group: `LifeSync Pro`
- Price target: `EUR 4.99/month`
- Intro offer: `7-day free trial`

## Review Notes

LifeSync AI is a personal daily activity journal. The first version uses CoreLocation visit monitoring, CoreMotion pedometer data, local notifications, StoreKit 2 subscriptions, and Unity Ads for rewarded/interstitial monetization on the free tier.

The AI summary in this build is generated locally as a deterministic preview of the daily report flow. No raw private messages, SMS content, call history, or screen recording data is collected. The DeviceActivity module is prepared for entitlement-approved Screen Time usage, but the first App Store build does not require reviewer access to private communication data.

Subscription testing:
- Product ID: `com.lifesync.ai.pro.monthly`
- Paywall: tap the Pro banner or Pro button.
- Free monetization: tap the daily summary button as a free user to trigger rewarded Unity Ads access.

Permissions used:
- Location: passive visit/significant-change monitoring for daily place count.
- Motion: step count and current movement status.
- Tracking transparency: requested before initializing Unity Ads where available.
- Notifications: nightly local reminder for the daily summary.

## Privacy Summary

- Data linked to user: none by default in this local-first build.
- Location: used on device for the daily activity journal.
- Fitness/motion: used on device for step/activity metrics.
- Advertising: Unity Ads may process ad delivery data for free-tier monetization.
- Purchases: StoreKit processes subscription transactions.

## Screenshot Files

Sized to Apple's current mandatory buckets (6.9" iPhone, 13" iPad); App Store Connect
scales these down to populate the smaller/older device buckets automatically.

- `app_store_screenshots/iphone_01_home_it.png` - iPhone 6.9", Italian home/activity dashboard, 1320x2868
- `app_store_screenshots/iphone_02_summary_en.png` - iPhone 6.9", English AI summary, 1320x2868
- `app_store_screenshots/iphone_03_paywall_es.png` - iPhone 6.9", Spanish paywall, 1320x2868
- `app_store_screenshots/iphone_04_privacy_fr.png` - iPhone 6.9", French communications/privacy panel, 1320x2868
- `app_store_screenshots/ipad_01_home_it.png` - iPad 13", Italian home/activity dashboard, 2064x2752
- `app_store_screenshots/ipad_02_paywall_en.png` - iPad 13", English paywall, 2064x2752

## Italian

Subtitle: Diario giornaliero con riepilogo AI

Promotional text: Traccia passi, luoghi e routine giornaliere con un riepilogo serale AI. Versione free con Unity Ads o Pro senza annunci.

Description:
LifeSync AI crea un diario giornaliero delle tue attivita usando sensori iOS ufficiali e un'esperienza progettata per la privacy.

Registra passi, luoghi visitati e stati di movimento, poi genera un riepilogo serale leggibile. Gli utenti free possono sbloccare alcune funzioni tramite video rewarded Unity Ads; LifeSync Pro rimuove gli annunci e abilita l'esperienza completa con prova gratuita di 7 giorni.

Funzioni principali:
- Diario giornaliero di passi e luoghi visitati
- Riepilogo assistente AI
- Notifica serale automatica
- Paywall StoreKit 2 con abbonamento mensile
- Monetizzazione free tier con Unity Ads
- Interfaccia localizzata in italiano, inglese, spagnolo e francese

## English

Subtitle: Daily journal with AI summaries

Promotional text: Track steps, places, and daily routines with an evening AI summary. Free tier with Unity Ads or Pro without ads.

Description:
LifeSync AI turns your daily activity into a simple personal journal using official iOS sensors and a privacy-minded experience.

Track steps, visited places, and movement status, then generate a readable evening summary. Free users can unlock selected flows with rewarded Unity Ads; LifeSync Pro removes ads and enables the complete experience with a 7-day free trial.

Key features:
- Daily journal for steps and visited places
- AI assistant summary
- Automatic evening notification
- StoreKit 2 monthly subscription
- Free-tier monetization with Unity Ads
- Localized interface in Italian, English, Spanish, and French

## Spanish

Subtitle: Diario diario con resumen IA

Promotional text: Registra pasos, lugares y rutinas diarias con un resumen nocturno IA. Versión gratis con Unity Ads o Pro sin anuncios.

Description:
LifeSync AI convierte tu actividad diaria en un diario personal usando sensores oficiales de iOS y una experiencia pensada para la privacidad.

Registra pasos, lugares visitados y estado de movimiento, y genera un resumen nocturno facil de leer. Los usuarios gratis pueden desbloquear funciones con videos rewarded de Unity Ads; LifeSync Pro elimina anuncios y habilita la experiencia completa con 7 dias de prueba gratis.

## French

Subtitle: Journal quotidien avec resume IA

Promotional text: Suivez pas, lieux et routines avec un resume IA du soir. Version gratuite avec Unity Ads ou Pro sans publicites.

Description:
LifeSync AI transforme votre activite quotidienne en journal personnel avec les capteurs iOS officiels et une experience respectueuse de la confidentialite.

Suivez vos pas, lieux visites et activites, puis genere un resume clair en fin de journee. Les utilisateurs gratuits peuvent debloquer certaines fonctions avec des videos Unity Ads; LifeSync Pro supprime les publicites et active l'experience complete avec 7 jours d'essai gratuit.
