import Foundation
import UserNotifications

/// Servizio per la generazione del riepilogo AI e la gestione delle notifiche locali schedulate alle 23:00
final class AISummarizerService {
    static let shared = AISummarizerService()
    
    private init() {}
    
    /// Configura la notifica automatica notturna per il riepilogo giornaliero
    func scheduleDailyNightlyNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted, error == nil else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "LifeSync AI - Riepilogo della Giornata"
            content.body = "Il tuo assistente ha sintetizzato i tuoi movimenti di oggi e creato il backup."
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 23
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "lifesync_nightly_summary", content: content, trigger: trigger)
            
            center.add(request) { err in
                if let err = err {
                    print("⚠️ Errore notifica: \(err.localizedDescription)")
                }
            }
        }
    }
    
    /// Richiede la sintesi AI del payload della giornata
    func fetchDailySummary(jsonPayload: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Simulazione o chiamata HTTPS sicura all'endpoint LLM / Apple Foundation Models
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
            let summary = """
            Riepilogo Assistente LifeSync AI
            
            Oggi hai mantenuto un eccellente livello di attività! 
            - Passi totali percorsi: Registrati con successo
            - Spostamenti e luoghi visitati: Monitorati tramite CoreLocation Visit API a basso consumo.
            - Backup di sicurezza: Salvato in archivio locale.
            
            Buon riposo per stasera!
            """
            completion(.success(summary))
        }
    }
}
