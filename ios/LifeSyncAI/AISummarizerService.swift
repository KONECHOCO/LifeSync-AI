import Foundation
import UserNotifications

/// Mostra le notifiche anche quando l'app è aperta (utile per la notifica di prova).
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

/// Servizio per il riepilogo giornaliero generato in locale e per la notifica serale.
final class AISummarizerService {
    static let shared = AISummarizerService()

    static let enabledKey = "nightlyEnabled"
    static let minutesKey = "nightlyMinutes"
    private let requestID = "lifesync_nightly_summary"

    private init() {}

    /// Ripianifica la notifica serale usando le impostazioni salvate (default: attiva, 23:00).
    func scheduleFromSettings() {
        let defaults = UserDefaults.standard
        let enabled = defaults.object(forKey: AISummarizerService.enabledKey) as? Bool ?? true
        let minutes = defaults.object(forKey: AISummarizerService.minutesKey) as? Int ?? (23 * 60)
        scheduleDailyNightlyNotification(enabled: enabled, hour: minutes / 60, minute: minutes % 60)
    }

    /// Configura (o rimuove) la notifica automatica serale per il riepilogo giornaliero
    func scheduleDailyNightlyNotification(enabled: Bool, hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
        guard enabled else { return }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { [requestID] granted, error in
            guard granted, error == nil else { return }

            let content = UNMutableNotificationContent()
            content.title = "notif_title".localized
            content.body = "notif_body".localized
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)

            center.add(request) { err in
                if let err = err {
                    print("⚠️ Errore notifica: \(err.localizedDescription)")
                }
            }
        }
    }

    /// Notifica di prova: arriva dopo pochi secondi.
    func sendTestNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted, error == nil else { return }

            let content = UNMutableNotificationContent()
            content.title = "notif_title".localized
            content.body = "notif_body".localized
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "lifesync_test_notification", content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
    }

    /// Riepilogo generato in locale sui dati reali della giornata (nessun dato lascia il dispositivo).
    func makeDailySummary(steps: Int, places: Int, averageSteps: Int?, activeMinutes: Int, notes: Int) -> String {
        var lines: [String] = [
            String(format: "sum_steps_line".localized, steps),
            String(format: "sum_places_line".localized, places)
        ]

        if activeMinutes > 0 {
            lines.append(String(format: "sum_active_line".localized, activeMinutes))
        }
        if notes > 0 {
            lines.append(String(format: "sum_notes_line".localized, notes))
        }

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
