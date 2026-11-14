# LifeSync AI - App Store Metadata

## App

- Name: LifeSync AI
- Bundle ID: `com.konechoco.lifesyncai`
- SKU: `lifesync-ai-ios`
- Category: Productivity
- Age rating: 4+
- Version: `1.1`
- In-app purchase: `com.lifesync.ai.pro.onetime` (non-consumable, one-time purchase)
- Price target: `EUR 3.99` (one time, no subscription)
- Companion app: Apple Watch (WatchConnectivity, embedded `com.konechoco.lifesyncai.watchkitapp`)

## Review Notes

LifeSync AI is a personal daily activity journal. The first version uses CoreLocation visit monitoring, CoreMotion pedometer data, local notifications, StoreKit 2 (one-time non-consumable purchase), and Unity Ads for rewarded/interstitial monetization on the free tier. The app opens with a short (3s, skippable) branded intro animation before showing the main screen.

The AI summary in this build is generated locally as a deterministic preview of the daily report flow. No raw private messages, SMS content, call history, or screen recording data is collected. The app does not include any Screen Time functionality and does not link or use the FamilyControls / DeviceActivity / ManagedSettings frameworks.

LifeSync AI Pro is a one-time purchase (not a subscription): it permanently removes ads and unlocks unlimited AI summaries plus CSV export. There is no recurring billing, trial period, or subscription to manage.

Purchase testing:
- Product ID: `com.lifesync.ai.pro.onetime`
- Paywall: tap the Pro banner or Pro tab.
- Free monetization: tap the daily summary button as a free user to trigger rewarded Unity Ads access.
- CSV export (Pro-only): tap "Export CSV" on the Today tab; a free user is routed to the paywall instead.

Apple Watch companion:
- A single-target watchOS app (`com.konechoco.lifesyncai.watchkitapp`) is embedded in the iPhone build.
- It shows today's steps, visited places, rest time and the latest AI summary, synced from the iPhone via WatchConnectivity (`updateApplicationContext`); pull-to-refresh on the Watch requests an immediate update if the iPhone is reachable.
- It has no permissions or sensors of its own: all data is read-only, mirrored from the iPhone app.

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
- Purchases: StoreKit processes a one-time, non-consumable purchase (no subscription).
- Apple Watch: today's steps/places/summary are mirrored to the paired Apple Watch via WatchConnectivity; this data never leaves the user's own devices.

## Screenshot Files

- `app_store_screenshots/01_home_it_6_7.png` - iPhone 6.7", Italian home/activity dashboard, 1290x2796
- `app_store_screenshots/02_summary_en_6_7.png` - iPhone 6.7", English summary flow, 1290x2796
- `app_store_screenshots/03_paywall_it_6_7.png` - iPhone 6.7", Italian paywall, 1290x2796
- `app_store_screenshots/04_monetization_es_5_5.png` - iPhone 5.5", Spanish dashboard, 1242x2208
- `app_store_screenshots/05_privacy_fr_ipad.png` - iPad, French privacy/monetization panel, 2048x2732

## Italian

Subtitle: Diario giornaliero con riepilogo AI

Promotional text: Traccia passi, luoghi e routine giornaliere con un riepilogo serale AI. Versione free con Unity Ads o Pro senza annunci con un acquisto unico di 3,99 €.

Description:
LifeSync AI crea un diario giornaliero delle tue attivita usando sensori iOS ufficiali e un'esperienza progettata per la privacy, con una companion app per Apple Watch.

Registra passi, luoghi visitati e stati di movimento, poi genera un riepilogo serale leggibile. Gli utenti free possono sbloccare alcune funzioni tramite video rewarded Unity Ads; con un acquisto unico di 3,99 € (nessun abbonamento) LifeSync Pro rimuove gli annunci, sblocca i riepiloghi illimitati e l'esportazione anche in CSV.

Funzioni principali:
- Diario giornaliero di passi e luoghi visitati
- Riepilogo assistente AI
- Notifica serale automatica
- Companion app per Apple Watch con il riepilogo di oggi
- LifeSync Pro: acquisto unico di 3,99 €, nessun abbonamento
- Monetizzazione free tier con Unity Ads
- Interfaccia localizzata in italiano, inglese, spagnolo e francese

## English

Subtitle: Daily journal with AI summaries

Promotional text: Track steps, places, and daily routines with an evening AI summary. Free tier with Unity Ads, or go ad-free Pro with a one-time €3.99 purchase.

Description:
LifeSync AI turns your daily activity into a simple personal journal using official iOS sensors and a privacy-minded experience, with an Apple Watch companion app.

Track steps, visited places, and movement status, then generate a readable evening summary. Free users can unlock selected flows with rewarded Unity Ads; a one-time €3.99 purchase (no subscription) unlocks LifeSync Pro: no ads, unlimited summaries, and CSV export.

Key features:
- Daily journal for steps and visited places
- AI assistant summary
- Automatic evening notification
- Apple Watch companion app with today's summary
- LifeSync Pro: one-time €3.99 purchase, no subscription
- Free-tier monetization with Unity Ads
- Localized interface in Italian, English, Spanish, and French

## Spanish

Subtitle: Diario diario con resumen IA

Promotional text: Registra pasos, lugares y rutinas diarias con un resumen nocturno IA. Versión gratis con Unity Ads o Pro sin anuncios con una compra única de 3,99 €.

Description:
LifeSync AI convierte tu actividad diaria en un diario personal usando sensores oficiales de iOS y una experiencia pensada para la privacidad, con una app complementaria para Apple Watch.

Registra pasos, lugares visitados y estado de movimiento, y genera un resumen nocturno facil de leer. Los usuarios gratis pueden desbloquear funciones con videos rewarded de Unity Ads; con una compra única de 3,99 € (sin suscripción) LifeSync Pro elimina los anuncios, desbloquea resúmenes ilimitados y la exportación en CSV.

Funciones principales:
- Diario diario de pasos y lugares visitados
- Resumen del asistente IA
- Notificación nocturna automática
- App complementaria para Apple Watch con el resumen de hoy
- LifeSync Pro: compra única de 3,99 €, sin suscripción
- Monetización de nivel gratuito con Unity Ads
- Interfaz localizada en italiano, inglés, español y francés

## French

Subtitle: Journal quotidien avec resume IA

Promotional text: Suivez pas, lieux et routines avec un resume IA du soir. Version gratuite avec Unity Ads ou Pro sans publicites avec un achat unique de 3,99 €.

Description:
LifeSync AI transforme votre activite quotidienne en journal personnel avec les capteurs iOS officiels et une experience respectueuse de la confidentialite, avec une application compagnon pour Apple Watch.

Suivez vos pas, lieux visites et activites, puis genere un resume clair en fin de journee. Les utilisateurs gratuits peuvent debloquer certaines fonctions avec des videos Unity Ads; avec un achat unique de 3,99 € (sans abonnement), LifeSync Pro supprime les publicites, debloque les resumes illimites et l'export CSV.

Fonctions principales:
- Journal quotidien des pas et lieux visites
- Resume de l'assistant IA
- Notification du soir automatique
- Application compagnon Apple Watch avec le resume du jour
- LifeSync Pro : achat unique de 3,99 €, sans abonnement
- Monetisation du niveau gratuit avec Unity Ads
- Interface localisee en italien, anglais, espagnol et francais
