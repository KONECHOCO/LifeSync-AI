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
            content.title = "notif_title".localized
            content.body = "notif_body".localized
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
    
    /// Riepilogo generato in locale sui dati reali della giornata (nessun dato lascia il dispositivo).
    func makeDailySummary(steps: Int, places: Int, averageSteps: Int?) -> String {
        var lines: [String] = [
            String(format: "sum_steps_line".localized, steps),
            String(format: "sum_places_line".localized, places)
        ]

        if let average = averageSteps, average > 0 {
            let diff = Int((Double(steps - average) / Double(average)) * 100.0)
            if diff >= 5 {
                lines.append(String(format: "sum_above".localized, diff))
            } else if diff <= -5 {
                lines.append(String(format: "sum_below".localized, abs(diff)))
            } else {
                lines.append("sum_same".localized)
            }
        } else {
            lines.append("sum_first".localized)
        }

        lines.append(steps >= 8000 ? "sum_close_active".localized : "sum_close_light".localized)
        return "sum_header".localized + "\n\n" + lines.joined(separator: "\n")
    }
}
