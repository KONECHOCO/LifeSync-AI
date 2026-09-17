// LifeSync AI - Complete i18n, StoreKit 2 Paywall, Unity Ads & Simulator Logic

// Initial State
let state = {
    currentLang: 'it',
    steps: 8420,
    placesCount: 4,
    sleepHours: "7h 20m",
    screenTimeMinutes: 165,
    waMinutes: 48,
    waNotifs: 14,
    phoneMinutes: 22,
    phoneCalls: 3,
    smsMinutes: 15,
    smsCount: 8,
    tgMinutes: 12,
    tgNotifs: 5,
    isProSubscribed: false,
    audioNotes: [
        { titleKey: "audioChip", duration: "0:34" }
    ],
    timeline: []
};

// Full Multi-Language Dictionary (IT, EN, ES, FR)
const i18n = {
    it: {
        navTagline: "Backup Giornaliero & Assistente Personale",
        tabDemo: "Simulator App",
        tabSwift: "Codice SwiftUI (Xcode)",
        tabPerf: "Performance & Privacy",
        greetingSub: "Bentornato,",
        cardToday: "Oggi, 17 Settembre",
        batteryUsage: "Batteria usata: 0.6%",
        lblSteps: "Passi",
        lblPlaces: "Luoghi",
        lblSleep: "Sonno (Health)",
        commsTitle: "Comunicazioni & Messaggi",
        commsBadge: "DeviceActivity API",
        commsDesc: "iOS protegge i testi e le chiamate private, ma consente di monitorare il tempo di utilizzo e le notifiche delle app:",
        lblPhoneApp: "Telefono / Chiamate",
        audioTitle: "Nota Vocale Rapida (Diario)",
        btnRecAudio: "Registra",
        audioDesc: "Aggiungi pensieri vocali al tuo backup che l'AI trascriverà ed integrerà nel report serale.",
        audioChip: "Idea riunione e lista spesa",
        timelineTitle: "Timeline Movimenti & Attività",
        btnAddEvent: "Simula Evento",
        aiCardTitle: "Riepilogo Assistente AI",
        btnGenerateAi: "Genera Ora",
        aiPlaceholder: "Fai clic su 'Genera Ora' o guarda uno spot Unity Ads per ricevere la sintesi AI della giornata.",
        icloudLock: "Backup Cifrato iCloud",
        backupTitle: "Stato Backup Giornaliero",
        backupDesc: "Tutti i log di movimento, tempo schermo e note vocali sono cifrati in locale.",
        btnDlJson: "Scarica JSON",
        btnSyncIcloud: "Sync iCloud",
        appToday: "Oggi",
        appHistory: "Storico",
        appStats: "Statistiche",
        appSettings: "Abbonamento",
        ctrlTitle: "Pannello Controllo & Monetizzazione",
        ctrlSubtitle: "Simula l'abbonamento con 7 giorni di prova gratis (€4,99/mese) e la rete Unity Ads.",
        privacyFaqTitle: "Registro Chiamate & SMS su iOS",
        privacyFaqDesc: "Per la massima privacy dell'App Store, iOS non permette di leggere testi o registro chiamate private. Tuttavia tramite DeviceActivity, EventKit e Siri Shortcuts è possibile monitorare minutaggio, sblocchi e trascrizioni vocali autorizzate.",
        simEventsTitle: "Aggiungi Eventi Simulatati",
        btnSimOffice: "Arrivo Ufficio",
        btnSimGym: "Sessione Palestra",
        btnSimWa: "+15m WhatsApp",
        btnSimCall: "Simula Chiamata",
        notifTitle: "Test Notifica Schedulata",
        notifDesc: "Simula l'arrivo della notifica serale delle ore 23:00 con il riepilogo automatico.",
        btnSendNotif: "Invia Notifica Notturna",
        paywallSubText: "Prova il backup illimitato per 7 giorni, poi 4,99 €/mese.",
        aiSummaryText: "🌟 **Sintesi Assistente AI del 17 Settembre**\n\nOggi hai registrato un ottimo equilibrio! Hai percorso **8.420 passi**, visitato **4 luoghi**, e accumulato **48 minuti di messaggistica su WhatsApp** e **3 chiamate (22m)**.\n\nHai completato 7h 20m di sonno profondo. Tutti i dati sono cifrati nel tuo backup giornaliero!",
        timelineItems: [
            { time: "08:15", title: "Risveglio & Corsa Mattutina", desc: "Parco Sempione • 4.2 km percorsi", icon: "fa-person-running", bg: "bg-cyan-light" },
            { time: "09:30", title: "Arrivo in Casa / Home Office", desc: "Connessione Wi-Fi Domestica rilevata", icon: "fa-house-laptop", bg: "bg-purple-light" },
            { time: "11:15", title: "Chiamata di Lavoro (Telefono)", desc: "Durata 18 min • Schedulata su Calendario", icon: "fa-phone", bg: "bg-green" },
            { time: "13:00", title: "Pausa Pranzo & Chat WhatsApp", desc: "48m di messaggistica attiva • Bar Motta", icon: "fa-comments", bg: "bg-gold-light" }
        ],
        simOfficeTitle: "Nuova Visita: Ufficio Central",
        simOfficeDesc: "Lavoro • Rilevato da CoreLocation Visit API",
        simGymTitle: "Nuova Visita: Palestra Fit Express",
        simGymDesc: "Fitness • Rilevato da CoreLocation Visit API",
        simCallTitle: "Chiamata di Lavoro (Telefono)",
        simCallDesc: "Durata 12 min • Tracciata da EventKit & DeviceActivity",
        simParkTitle: "Nuova Visita: Parco Centrale",
        simParkDesc: "Passeggiata • Rilevato da CoreLocation Visit API"
    },
    en: {
        navTagline: "Daily Backup & Personal Assistant",
        tabDemo: "App Simulator",
        tabSwift: "SwiftUI Code (Xcode)",
        tabPerf: "Performance & Privacy",
        greetingSub: "Welcome back,",
        cardToday: "Today, September 17",
        batteryUsage: "Battery used: 0.6%",
        lblSteps: "Steps",
        lblPlaces: "Places",
        lblSleep: "Sleep (Health)",
        commsTitle: "Communications & Messages",
        commsBadge: "DeviceActivity API",
        commsDesc: "iOS protects private texts & calls, but allows tracking app screen time & notification counts:",
        lblPhoneApp: "Phone / Calls",
        audioTitle: "Quick Audio Note (Journal)",
        btnRecAudio: "Record",
        audioDesc: "Add voice notes to your daily backup; the AI will transcribe & summarize them tonight.",
        audioChip: "Meeting idea & shopping list",
        timelineTitle: "Timeline & Activity Log",
        btnAddEvent: "Simulate Event",
        aiCardTitle: "AI Assistant Summary",
        btnGenerateAi: "Generate Now",
        aiPlaceholder: "Click 'Generate Now' or watch a Unity Ads video to receive your daily automated narrative backup.",
        icloudLock: "iCloud Encrypted Backup",
        backupTitle: "Daily Backup Status",
        backupDesc: "All movement logs, screen time, and audio notes are encrypted locally.",
        btnDlJson: "Download JSON",
        btnSyncIcloud: "Sync iCloud",
        appToday: "Today",
        appHistory: "History",
        appStats: "Stats",
        appSettings: "Subscription",
        ctrlTitle: "Control & Monetization Panel",
        ctrlSubtitle: "Simulate €4.99/mo subscription with 7-day free trial & Unity Ads network.",
        privacyFaqTitle: "Call Logs & SMS on iOS",
        privacyFaqDesc: "To ensure App Store compliance, iOS blocks reading raw call history & private SMS texts. DeviceActivity, EventKit & Siri Shortcuts enable tracking usage minutes, pickups & authorized transcripts.",
        simEventsTitle: "Add Simulated Events",
        btnSimOffice: "Arrive Office",
        btnSimGym: "Gym Session",
        btnSimWa: "+15m WhatsApp",
        btnSimCall: "Simulate Call",
        notifTitle: "Scheduled Notification Test",
        notifDesc: "Simulate the 11:00 PM nightly notification with the automated summary.",
        btnSendNotif: "Send Nightly Notification",
        paywallSubText: "Try unlimited backup for 7 days, then €4.99/month.",
        aiSummaryText: "🌟 **AI Assistant Daily Summary - Sept 17**\n\nGreat daily balance today! You walked **8,420 steps**, visited **4 places**, spent **48 mins on WhatsApp**, and logged **3 calls (22 mins)**.\n\nYou achieved 7h 20m of deep sleep. All logs are securely backed up to your encrypted iCloud archive!",
        timelineItems: [
            { time: "08:15", title: "Morning Run & Wake Up", desc: "Central Park • 4.2 km completed", icon: "fa-person-running", bg: "bg-cyan-light" },
            { time: "09:30", title: "Arrive Home / Home Office", desc: "Home Wi-Fi Network Connected", icon: "fa-house-laptop", bg: "bg-purple-light" },
            { time: "11:15", title: "Work Call (Phone)", desc: "18 min duration • Scheduled on Calendar", icon: "fa-phone", bg: "bg-green" },
            { time: "13:00", title: "Lunch Break & WhatsApp Chat", desc: "48m active messaging • Motta Cafe", icon: "fa-comments", bg: "bg-gold-light" }
        ],
        simOfficeTitle: "New Visit: Central Office",
        simOfficeDesc: "Work • Detected by CoreLocation Visit API",
        simGymTitle: "New Visit: Fit Express Gym",
        simGymDesc: "Fitness • Detected by CoreLocation Visit API",
        simCallTitle: "Work Call (Phone)",
        simCallDesc: "12 min duration • Tracked by EventKit & DeviceActivity",
        simParkTitle: "New Visit: Central Park",
        simParkDesc: "Outdoor Walk • Detected by CoreLocation Visit API"
    },
    es: {
        navTagline: "Copia de Seguridad Diaria y Asistente Personal",
        tabDemo: "Simulador de App",
        tabSwift: "Código SwiftUI (Xcode)",
        tabPerf: "Rendimiento y Privacidad",
        greetingSub: "Bienvenido,",
        cardToday: "Hoy, 17 de Septiembre",
        batteryUsage: "Batería usada: 0.6%",
        lblSteps: "Pasos",
        lblPlaces: "Lugares",
        lblSleep: "Sueño (Salud)",
        commsTitle: "Comunicaciones y Mensajes",
        commsBadge: "DeviceActivity API",
        commsDesc: "iOS protege textos y llamadas privadas, pero permite medir tiempo de pantalla y notificaciones:",
        lblPhoneApp: "Teléfono / Llamadas",
        audioTitle: "Nota de Voz Rápida (Diario)",
        btnRecAudio: "Grabar",
        audioDesc: "Añade pensamientos de voz a tu copia de seguridad; la IA los transcribirá esta noche.",
        audioChip: "Idea de reunión y lista de compras",
        timelineTitle: "Línea de Tiempo y Actividades",
        btnAddEvent: "Simular Evento",
        aiCardTitle: "Resumen de Asistente IA",
        btnGenerateAi: "Generar Ahora",
        aiPlaceholder: "Haz clic en 'Generar Ahora' o mira un anuncio de Unity Ads para recibir tu resumen.",
        icloudLock: "Copia Cifrada en iCloud",
        backupTitle: "Estado de la Copia Diaria",
        backupDesc: "Todos los registros de movimiento y voz están cifrados localmente.",
        btnDlJson: "Descargar JSON",
        btnSyncIcloud: "Sync iCloud",
        appToday: "Hoy",
        appHistory: "Historial",
        appStats: "Estadísticas",
        appSettings: "Suscripción",
        ctrlTitle: "Panel de Control y Monetización",
        ctrlSubtitle: "Simula la suscripción de 4,99 €/mes con 7 días gratis y Unity Ads.",
        privacyFaqTitle: "Registro de Llamadas y SMS en iOS",
        privacyFaqDesc: "Por normas de App Store, iOS no permite leer mensajes de texto ni llamadas privadas. DeviceActivity y EventKit permiten registrar minutos de uso y llamadas en calendario.",
        simEventsTitle: "Añadir Eventos Simulados",
        btnSimOffice: "Llegada Oficina",
        btnSimGym: "Sesión Gimnasio",
        btnSimWa: "+15m WhatsApp",
        btnSimCall: "Simular Llamada",
        notifTitle: "Prueba de Notificación Programada",
        notifDesc: "Simula la llegada de la notificación nocturna de las 23:00.",
        btnSendNotif: "Enviar Notificación Nocturna",
        paywallSubText: "Prueba copia ilimitada 7 días gratis, luego 4,99 €/mes.",
        aiSummaryText: "🌟 **Resumen del Asistente IA - 17 Sept**\n\n¡Excelente equilibrio diario! Registraste **8.420 pasos**, visitaste **4 lugares**, usaste **48m en WhatsApp** y **3 llamadas (22m)**.\n\nDurmiste 7h 20m. ¡Todos los datos están guardados en tu copia cifrada!",
        timelineItems: [
            { time: "08:15", title: "Despertar y Carrera Matutina", desc: "Parque Central • 4.2 km recorridos", icon: "fa-person-running", bg: "bg-cyan-light" },
            { time: "09:30", title: "Llegada a Casa / Oficina en Casa", desc: "Conectado a Wi-Fi Doméstico", icon: "fa-house-laptop", bg: "bg-purple-light" },
            { time: "11:15", title: "Llamada de Trabajo (Teléfono)", desc: "Duración 18 min • Programada en Calendario", icon: "fa-phone", bg: "bg-green" },
            { time: "13:00", title: "Pausa Almuerzo y Chat WhatsApp", desc: "48m de mensajería activa • Café Motta", icon: "fa-comments", bg: "bg-gold-light" }
        ],
        simOfficeTitle: "Nueva Visita: Oficina Central",
        simOfficeDesc: "Trabajo • Detectado por API CoreLocation Visit",
        simGymTitle: "Nueva Visita: Gimnasio Fit Express",
        simGymDesc: "Fitness • Detectado por API CoreLocation Visit",
        simCallTitle: "Llamada de Trabajo (Teléfono)",
        simCallDesc: "Duración 12 min • Rastreado por EventKit y DeviceActivity",
        simParkTitle: "Nueva Visita: Parque Central",
        simParkDesc: "Paseo al Aire Libre • Detectado por API CoreLocation Visit"
    },
    fr: {
        navTagline: "Sauvegarde Quotidienne & Assistant Personnel",
        tabDemo: "Simulateur d'Application",
        tabSwift: "Code SwiftUI (Xcode)",
        tabPerf: "Performance & Confidentialité",
        greetingSub: "Bon retour,",
        cardToday: "Aujourd'hui, 17 Septembre",
        batteryUsage: "Batterie utilisée: 0.6%",
        lblSteps: "Pas",
        lblPlaces: "Lieux",
        lblSleep: "Sommeil (Santé)",
        commsTitle: "Communications & Messages",
        commsBadge: "DeviceActivity API",
        commsDesc: "iOS protège les SMS & appels privés, mais permet de mesurer le temps d'écran et les notifications :",
        lblPhoneApp: "Téléphone / Appels",
        audioTitle: "Note Vocale Rapida (Journal)",
        btnRecAudio: "Enregistrer",
        audioDesc: "Ajoutez vos pensées vocales; l'IA les transcrira et résumera ce soir.",
        audioChip: "Idée de réunion & liste de courses",
        timelineTitle: "Chronologie & Activités",
        btnAddEvent: "Simuler Événement",
        aiCardTitle: "Résumé de l'Assistant IA",
        btnGenerateAi: "Générer Maintenant",
        aiPlaceholder: "Cliquez sur 'Générer Maintenant' ou regardez une publicité Unity Ads pour débloquer votre résumé.",
        icloudLock: "Sauvegarde Chiffrée iCloud",
        backupTitle: "Statut de la Sauvegarde",
        backupDesc: "Tous vos journaux de mouvement et vocaux sont chiffrés localement.",
        btnDlJson: "Télécharger JSON",
        btnSyncIcloud: "Sync iCloud",
        appToday: "Aujourd'hui",
        appHistory: "Historique",
        appStats: "Statistiques",
        appSettings: "Abonnement",
        ctrlTitle: "Panneau de Contrôle & Monétisation",
        ctrlSubtitle: "Simulez l'abonnement 4,99 €/mois (7 jours gratuits) et le réseau Unity Ads.",
        privacyFaqTitle: "Journal d'Appels & SMS sur iOS",
        privacyFaqDesc: "Pour respecter l'App Store, iOS empêche la lecture directe des SMS & appels. DeviceActivity et EventKit permettent de suivre l'utilisation et les rendez-vous.",
        simEventsTitle: "Ajouter des Événements Simulés",
        btnSimOffice: "Arrivée Bureau",
        btnSimGym: "Séance Sport",
        btnSimWa: "+15m WhatsApp",
        btnSimCall: "Simuler Appel",
        notifTitle: "Test de Notification Programmée",
        notifDesc: "Simulez la réception de la notification de 23h00.",
        btnSendNotif: "Envoyer Notification",
        paywallSubText: "Essai gratuit 7 jours, puis 4,99 €/mois.",
        aiSummaryText: "🌟 **Résumé de l'Assistant IA - 17 Sept**\n\nExcellente journée ! Vous avez accompli **8 420 pas**, visité **4 lieux**, passé **48m sur WhatsApp** et **3 appels (22m)**.\n\nSommeil réparateur de 7h 20m. Toutes vos données sont sauvegardées en toute sécurité !",
        timelineItems: [
            { time: "08:15", title: "Réveil & Course Matinale", desc: "Parc Sempione • 4.2 km parcourus", icon: "fa-person-running", bg: "bg-cyan-light" },
            { time: "09:30", title: "Arrivée Maison / Bureau à Domicile", desc: "Connexion Wi-Fi Domestique Détectée", icon: "fa-house-laptop", bg: "bg-purple-light" },
            { time: "11:15", title: "Appel de Travail (Téléphone)", desc: "Durée 18 min • Programmé sur le Calendrier", icon: "fa-phone", bg: "bg-green" },
            { time: "13:00", title: "Pause Déjeuner & Chat WhatsApp", desc: "48m de messagerie active • Café Motta", icon: "fa-comments", bg: "bg-gold-light" }
        ],
        simOfficeTitle: "Nouvelle Visite : Bureau Central",
        simOfficeDesc: "Travail • Détecté par l'API CoreLocation Visit",
        simGymTitle: "Nouvelle Visite : Salle de Sport Fit Express",
        simGymDesc: "Fitness • Détecté par l'API CoreLocation Visit",
        simCallTitle: "Appel de Travail (Téléphone)",
        simCallDesc: "Durée 12 min • Suivi par EventKit & DeviceActivity",
        simParkTitle: "Nouvelle Visite : Parc Central",
        simParkDesc: "Promenade Extérieure • Détectée par l'API CoreLocation Visit"
    }
};

// Swift Code Samples for Viewer
const swiftFiles = {
    'UnityAdsManager': `import Foundation
import UIKit
import StoreKit

/// Manager Unity Ads Monetization (Game ID: 687287710)
final class UnityAdsManager: NSObject, ObservableObject {
    static let shared = UnityAdsManager()
    static let unityGameID = "687287710"
    static let rewardedPlacementID = "Rewarded_iOS"
    static let interstitialPlacementID = "Interstitial_iOS"
    
    @Published var isRewardedAdReady: Bool = true
    
    func showRewardedAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        // Mostra spot video e concede la ricompensa al termine
        print("🎬 Unity Ads Video Rewarded in riproduzione...")
        completion(true)
    }
}`,

    'SubscriptionManager': `import Foundation
import StoreKit

/// Manager Abbonamenti In-App Purchase tramite StoreKit 2
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    static let monthlySubscriptionID = "com.lifesync.ai.pro.monthly"
    
    @Published var subscriptionProduct: Product?
    @Published var isSubscribed: Bool = false
    
    @MainActor
    func purchaseMonthlySubscription() async -> Bool {
        guard let product = subscriptionProduct else { return false }
        let result = try? await product.purchase()
        if case .success = result {
            self.isSubscribed = true
            return true
        }
        return false
    }
}`,

    'PaywallView': `import SwiftUI

struct PaywallView: View {
    @Environment(\\.dismiss) private var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    
    var body: some View {
        ZStack {
            Color(red: 9/255, green: 13/255, blue: 22/255).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("LifeSync AI Pro").font(.largeTitle).bold()
                Text("7 GIORNI DI PROVA GRATUITA").font(.caption).bold().foregroundColor(.yellow)
            }
        }
    }
}`,

    'LocalizationManager': `import Foundation

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    @Published var currentLanguage: String = "it"
}`,

    'DeviceActivityManager': `import Foundation
import DeviceActivity

final class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    @Published var whatsappMinutesToday: Int = 48
}`,

    'LocationManager': `import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
}`,

    'MotionTracker': `import Foundation
import CoreMotion

final class MotionTracker: ObservableObject {
    private let pedometer = CMPedometer()
}`,

    'DailyLogAggregator': `import Foundation
import SwiftData

@Model
final class DailyBackupLog {
    var dateString: String
    var stepsCount: Int
}`,

    'AISummarizerService': `import Foundation

final class AISummarizerService {
    static let shared = AISummarizerService()
}`,

    'ContentView': `import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("LifeSync AI Pro")
        }
    }
}`
};

// Initialize App
document.addEventListener("DOMContentLoaded", () => {
    updateClock();
    setInterval(updateClock, 1000);
    
    state.timeline = [...i18n.it.timelineItems];
    renderTimeline();
    loadSwiftFile('UnityAdsManager');
});

// Unity Ads Video Modal Simulation
function simulateUnityAdVideo() {
    const modal = document.getElementById('unity-ad-video-modal');
    const timerEl = document.getElementById('unity-ad-timer');
    if (!modal) return;
    
    modal.classList.add('active');
    let secondsLeft = 5;
    if (timerEl) timerEl.textContent = `00:0${secondsLeft}`;
    
    const countdown = setInterval(() => {
        secondsLeft--;
        if (timerEl) timerEl.textContent = `00:0${secondsLeft}`;
        if (secondsLeft <= 0) {
            clearInterval(countdown);
            modal.classList.remove('active');
            alert("🎬 Unity Ads Rewarded Video Completato! Ricompensa registrata. Ora generiamo il tuo report AI.");
            generateAISummary();
        }
    }, 1000);
}

// Paywall Modal Functions
function openPaywallModal() {
    const modal = document.getElementById('paywall-modal');
    if (modal) modal.classList.add('active');
}

function closePaywallModal() {
    const modal = document.getElementById('paywall-modal');
    if (modal) modal.classList.remove('active');
}

function simulateSubscribe() {
    state.isProSubscribed = true;
    alert("🎉 Prova di 7 Giorni Attivata! Primo addebito di €4,99/mese posticipato all'8° giorno.");
    closePaywallModal();
}

// Switch Language and Translate ALL Elements Dynamically
function changeLanguage(lang) {
    if (!i18n[lang]) return;
    state.currentLang = lang;
    const t = i18n[lang];
    
    document.getElementById('txt-nav-tagline').textContent = t.navTagline;
    document.getElementById('txt-tab-demo').textContent = t.tabDemo;
    document.getElementById('txt-tab-swift').textContent = t.tabSwift;
    document.getElementById('txt-tab-perf').textContent = t.tabPerf;
    
    document.getElementById('txt-greeting-sub').textContent = t.greetingSub;
    document.getElementById('txt-card-today').innerHTML = `<i class="fa-solid fa-calendar-day icon-glow"></i> ${t.cardToday}`;
    document.getElementById('txt-battery-usage').textContent = t.batteryUsage;
    document.getElementById('lbl-steps').textContent = t.lblSteps;
    document.getElementById('lbl-places').textContent = t.lblPlaces;
    document.getElementById('lbl-sleep').textContent = t.lblSleep;
    
    document.getElementById('txt-comms-title').textContent = t.commsTitle;
    document.getElementById('txt-comms-badge').textContent = t.commsBadge;
    document.getElementById('txt-comms-desc').textContent = t.commsDesc;
    document.getElementById('lbl-phone-app').textContent = t.lblPhoneApp;
    
    document.getElementById('txt-audio-title').textContent = t.audioTitle;
    document.getElementById('btn-rec-audio').textContent = t.btnRecAudio;
    document.getElementById('txt-audio-desc').textContent = t.audioDesc;
    document.getElementById('txt-paywall-sub').textContent = t.paywallSubText;
    
    const audioList = document.getElementById('audio-notes-list');
    if (audioList) {
        audioList.innerHTML = `<div class="audio-chip"><i class="fa-solid fa-waveform"></i> "${t.audioChip}" (0:34)</div>`;
    }
    
    document.getElementById('txt-timeline-title').textContent = t.timelineTitle;
    document.getElementById('btn-add-event').textContent = t.btnAddEvent;
    
    state.timeline = [...t.timelineItems];
    renderTimeline();
    
    document.getElementById('txt-ai-card-title').textContent = t.aiCardTitle;
    document.getElementById('btn-generate-ai').textContent = t.btnGenerateAi;
    
    const summaryBox = document.getElementById('ai-summary-text');
    if (summaryBox) {
        summaryBox.innerHTML = `<p class="placeholder-text">${t.aiPlaceholder}</p>`;
    }
    
    document.getElementById('txt-icloud-lock').textContent = t.icloudLock;
    document.getElementById('txt-backup-title').textContent = t.backupTitle;
    document.getElementById('txt-backup-desc').textContent = t.backupDesc;
    document.getElementById('btn-dl-json').textContent = t.btnDlJson;
    document.getElementById('btn-sync-icloud').textContent = t.btnSyncIcloud;
    
    document.getElementById('tab-app-today').textContent = t.appToday;
    document.getElementById('tab-app-history').textContent = t.appHistory;
    document.getElementById('tab-app-stats').textContent = t.appStats;
    document.getElementById('tab-app-settings').textContent = t.appSettings;
    
    document.getElementById('txt-ctrl-title').textContent = t.ctrlTitle;
    document.getElementById('txt-ctrl-subtitle').textContent = t.ctrlSubtitle;
    document.getElementById('txt-privacy-faq-title').textContent = t.privacyFaqTitle;
    document.getElementById('txt-privacy-faq-desc').innerHTML = t.privacyFaqDesc;
    document.getElementById('txt-sim-events-title').textContent = t.simEventsTitle;
    document.getElementById('btn-sim-office').textContent = t.btnSimOffice;
    document.getElementById('btn-sim-gym').textContent = t.btnSimGym;
    document.getElementById('btn-sim-wa').textContent = t.btnSimWa;
    document.getElementById('btn-sim-call').textContent = t.btnSimCall;
    document.getElementById('txt-notif-title').textContent = t.notifTitle;
    document.getElementById('txt-notif-desc').textContent = t.notifDesc;
    document.getElementById('btn-send-notif').textContent = t.btnSendNotif;
}

function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const phoneClock = document.getElementById('live-phone-time');
    if (phoneClock) phoneClock.textContent = `${hours}:${minutes}`;
}

function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));
    
    const targetTab = document.getElementById(`tab-${tabName}`);
    const targetBtn = document.getElementById(`nav-${tabName}-btn`);
    if (targetTab) targetTab.classList.add('active');
    if (targetBtn) targetBtn.classList.add('active');
}

function renderTimeline() {
    const container = document.getElementById('timeline-list');
    if (!container) return;
    
    container.innerHTML = state.timeline.map(item => `
        <div class="timeline-item">
            <span class="timeline-time">${item.time}</span>
            <div class="timeline-icon-box ${item.bg}">
                <i class="fa-solid ${item.icon}"></i>
            </div>
            <div class="timeline-details">
                <h5>${item.title}</h5>
                <p>${item.desc}</p>
            </div>
        </div>
    `).join('');
    
    document.getElementById('val-steps').textContent = state.steps.toLocaleString();
    document.getElementById('val-places').textContent = state.placesCount;
    document.getElementById('val-sleep').textContent = state.sleepHours;
    document.getElementById('val-wa-time').textContent = `${state.waMinutes}m • ${state.waNotifs} notif`;
    document.getElementById('val-phone-time').textContent = `${state.phoneMinutes}m • ${state.phoneCalls} calls`;
}

function simulateMessagingActivity(appName, extraMins) {
    state.waMinutes += extraMins;
    state.waNotifs += 4;
    renderTimeline();
}

function simulateCallActivity() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const t = i18n[state.currentLang];
    
    state.phoneMinutes += 12;
    state.phoneCalls += 1;
    
    state.timeline.unshift({
        time: `${hours}:${minutes}`,
        title: t.simCallTitle,
        desc: t.simCallDesc,
        icon: "fa-phone",
        bg: "bg-cyan-light"
    });
    
    renderTimeline();
}

function recordAudioNote() {
    const defaultPrompt = state.currentLang === 'it' ? "Titolo della nota vocale:" : "Audio note title:";
    const title = prompt(defaultPrompt, "Idea project & shopping");
    if (!title) return;
    
    state.audioNotes.push({ title: title, duration: "0:45" });
    
    const list = document.getElementById('audio-notes-list');
    if (list) {
        list.innerHTML += `<div class="audio-chip"><i class="fa-solid fa-waveform"></i> "${title}" (0:45)</div>`;
    }
}

function simulateLocation(placeName, categoryKey) {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const t = i18n[state.currentLang];
    
    state.placesCount++;
    state.steps += 750;
    
    let title = t.simOfficeTitle;
    let desc = t.simOfficeDesc;
    
    if (categoryKey.includes('Gym') || categoryKey.includes('Fitness')) {
        title = t.simGymTitle;
        desc = t.simGymDesc;
    } else if (categoryKey.includes('Park') || categoryKey.includes('Passeggiata')) {
        title = t.simParkTitle;
        desc = t.simParkDesc;
    }
    
    state.timeline.unshift({
        time: `${hours}:${minutes}`,
        title: title,
        desc: desc,
        icon: "fa-map-pin",
        bg: "bg-purple-light"
    });
    
    renderTimeline();
}

function addSimulatedEvent() {
    simulateLocation("Parco Centrale", "Park");
}

function generateAISummary() {
    const summaryBox = document.getElementById('ai-summary-text');
    const btn = document.getElementById('generate-ai-btn');
    const timeTag = document.getElementById('last-generated-time');
    
    if (!summaryBox || !btn) return;
    
    btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> ...`;
    btn.disabled = true;
    
    const textToType = i18n[state.currentLang].aiSummaryText;
    summaryBox.innerHTML = "";
    
    setTimeout(() => {
        let i = 0;
        function typeWriter() {
            if (i < textToType.length) {
                const char = textToType.charAt(i);
                if (char === '\n') {
                    summaryBox.innerHTML += '<br>';
                } else {
                    summaryBox.innerHTML += char;
                }
                i++;
                setTimeout(typeWriter, 10);
            } else {
                btn.innerHTML = `<i class="fa-solid fa-check text-green"></i> OK`;
                btn.disabled = false;
                const now = new Date();
                if (timeTag) timeTag.textContent = `${now.toLocaleTimeString()}`;
            }
        }
        typeWriter();
    }, 600);
}

function triggerBackupDownload() {
    const backupData = {
        app: "LifeSync AI",
        language: state.currentLang,
        subscriptionStatus: state.isProSubscribed ? "Active 7-Day Free Trial" : "Free Tier (Unity Ads Enabled)",
        exportDate: new Date().toISOString(),
        user: "Marco Rossi",
        dailyMetrics: {
            steps: state.steps,
            placesCount: state.placesCount,
            sleepHours: state.sleepHours,
            messagingAppMinutes: {
                whatsApp: state.waMinutes,
                phoneCallsMinutes: state.phoneMinutes,
                smsMinutes: state.smsMinutes
            }
        },
        audioNotes: state.audioNotes,
        timelineEvents: state.timeline
    };
    
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(backupData, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute("href", dataStr);
    downloadAnchor.setAttribute("download", `LifeSync_${state.currentLang.toUpperCase()}_Backup_${new Date().toISOString().slice(0,10)}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
}

function simulateCloudSync() {
    alert("☁️ iCloud Sync Successful! Backup encrypted with AES-256.");
}

function simulatePushNotification() {
    const banner = document.getElementById('push-notification-banner');
    if (!banner) return;
    
    const t = i18n[state.currentLang];
    document.getElementById('txt-notif-banner-title').textContent = `${t.aiCardTitle} 🌙`;
    document.getElementById('txt-notif-banner-body').textContent = `${t.lblSteps}: ${state.steps.toLocaleString()}, WhatsApp: ${state.waMinutes}m, ${t.lblPlaces}: ${state.placesCount}.`;
    
    banner.classList.add('show');
    setTimeout(() => banner.classList.remove('show'), 5000);
}

function loadSwiftFile(filename) {
    document.querySelectorAll('.swift-file-item').forEach(el => el.classList.remove('active'));
    
    const items = document.querySelectorAll('.swift-file-item');
    items.forEach(item => {
        if (item.textContent.includes(filename)) {
            item.classList.add('active');
        }
    });
    
    const titleEl = document.getElementById('active-filename');
    const codeEl = document.getElementById('code-block');
    
    if (titleEl) titleEl.textContent = `${filename}.swift`;
    if (codeEl && swiftFiles[filename]) {
        codeEl.textContent = swiftFiles[filename];
    }
}

function copySwiftCode() {
    const codeEl = document.getElementById('code-block');
    if (codeEl) {
        navigator.clipboard.writeText(codeEl.textContent);
        alert("📋 Swift code copied to clipboard!");
    }
}
