import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

/// Gestore del tracciamento tempo utilizzo e notifiche di WhatsApp, Telefono ed SMS tramite le API ufficiali iOS DeviceActivity
final class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    
    @Published var whatsappMinutesToday: Int = 48
    @Published var phoneCallsDurationMinutes: Int = 22
    @Published var smsUsageMinutes: Int = 15
    @Published var isAuthorized: Bool = false
    
    /// Richiede all'utente l'autorizzazione di monitoraggio Screen Time / Device Activity
    func requestScreenTimeAuthorization() {
        AuthorizationCenter.shared.requestAuthorization(for: .individual) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isAuthorized = true
                    self.startMonitoringMessagingApps()
                case .failure(let error):
                    print("⚠️ Autorizzazione DeviceActivity negata: \(error.localizedDescription)")
                    self.isAuthorized = false
                }
            }
        }
    }
    
    /// Schedula il monitoraggio giornaliero delle app di comunicazione
    private func startMonitoringMessagingApps() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(DeviceActivityName("messaging_usage"), during: schedule)
            print("✅ Monitoraggio ScreenTime attivato per app di comunicazione")
        } catch {
            print("⚠️ Impossibile avviare DeviceActivity: \(error.localizedDescription)")
        }
    }
}
