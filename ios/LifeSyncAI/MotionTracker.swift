import Foundation
import CoreMotion
import Combine

/// Tracker di movimento e conteggio passi tramite chip hardware integrato (CMPedometer)
final class MotionTracker: ObservableObject {
    
    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    
    @Published var stepsToday: Int = 0
    @Published var distanceMeters: Double = 0.0
    @Published var currentActivity: String = "Stazionario"
    
    func startTracking() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        // Recupera ed aggiorna i passi tramite l'hardware a basso consumo
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.stepsToday = data.numberOfSteps.intValue
                self?.distanceMeters = data.distance?.doubleValue ?? 0.0
                
                DailyLogAggregator.shared.updateSteps(data.numberOfSteps.intValue)
            }
        }
        
        // Rileva lo stato di movimento (Camminata, Corsa, In Veicolo)
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let activity = activity else { return }
                
                if activity.running {
                    self?.currentActivity = "Corsa"
                } else if activity.walking {
                    self?.currentActivity = "Camminata"
                } else if activity.automotive {
                    self?.currentActivity = "In Guida / Veicolo"
                } else if activity.cycling {
                    self?.currentActivity = "In Bicicletta"
                } else {
                    self?.currentActivity = "Stazionario"
                }
            }
        }
    }
}
