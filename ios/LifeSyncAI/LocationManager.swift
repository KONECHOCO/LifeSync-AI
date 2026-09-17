import Foundation
import CoreLocation
import Combine

/// Manager per il monitoraggio della posizione ottimizzato per batteria e linee guida App Store.
/// Utilizza `CLVisit` e `Significant Location Changes` (nessun consumo GPS continuativo al metro).
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    @Published var lastVisitedPlace: String = "In attesa di posizione..."
    @Published var visitsCountToday: Int = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    /// Richiede le autorizzazioni di tracciamento e avvia i sensori a basso consumo
    func requestPermissionsAndStart() {
        locationManager.requestAlwaysAuthorization()
        
        // Modalità ad altissima efficienza energetica (<0.5% batteria/giorno)
        locationManager.startMonitoringVisits()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }
    
    /// Callback invocata da iOS quando l'utente si ferma o riparte da un luogo
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let isArrival = visit.departureDate == Date.distantFuture
        
        if isArrival {
            let lat = visit.coordinate.latitude
            let lon = visit.coordinate.longitude
            
            DispatchQueue.main.async {
                self.visitsCountToday += 1
                self.lastVisitedPlace = "Luogo #\(self.visitsCountToday) (\(String(format: "%.3f", lat)), \(String(format: "%.3f", lon)))"
                
                // Salva nel log di giornata
                DailyLogAggregator.shared.recordLocationEvent(latitude: lat, longitude: lon, date: visit.arrivalDate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Errore CoreLocation: \(error.localizedDescription)")
    }
}
