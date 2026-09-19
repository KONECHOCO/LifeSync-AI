import Foundation
import CoreLocation
import SwiftData
import Combine

/// Manager per il monitoraggio della posizione ottimizzato per batteria e linee guida App Store.
/// Utilizza `CLVisit` e `Significant Location Changes` (nessun consumo GPS continuativo al metro).
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var lastVisitedPlace: String = "..."
    @Published var visitsCountToday: Int = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        authorizationStatus = locationManager.authorizationStatus
    }

    /// Richiede le autorizzazioni di tracciamento e avvia i sensori a basso consumo
    func requestPermissionsAndStart() {
        locationManager.requestAlwaysAuthorization()
        startMonitoring()
    }

    /// Riprende il monitoraggio all'avvio dell'app se l'utente ha già dato il permesso.
    func resumeIfAuthorized() {
        let status = locationManager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startMonitoring()
        }
    }

    private func startMonitoring() {
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
        guard isArrival else { return }

        let latitude = visit.coordinate.latitude
        let longitude = visit.coordinate.longitude
        let arrival = visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate
        let coordinateText = String(format: "%.3f, %.3f", latitude, longitude)

        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let placemark = placemarks?.first
            let name = placemark?.name ?? placemark?.thoroughfare ?? coordinateText
            DispatchQueue.main.async {
                self?.registerVisit(name: name, coordinateText: coordinateText, arrival: arrival)
            }
        }
    }

    private func registerVisit(name: String, coordinateText: String, arrival: Date) {
        if Calendar.current.isDateInToday(arrival) {
            visitsCountToday += 1
        }
        lastVisitedPlace = name

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let entry = "[\(timeFormatter.string(from: arrival))] \(name)"
        DailyLogAggregator.shared.recordPlace(entry)

        // Salvataggio indipendente dalle schermate: funziona anche se iOS avvia l'app in background.
        let context = ModelContext(LocalStore.container)
        DailyLogStore.upsert(
            dateString: DailyLogStore.key(for: arrival),
            steps: nil,
            places: [entry],
            summary: nil,
            in: context
        )
        TimelineStore.add(
            id: "visit-\(Int(arrival.timeIntervalSince1970))",
            date: arrival,
            kind: "visit",
            title: "\("tl_visit".localized): \(name)",
            detail: coordinateText,
            in: context
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Errore CoreLocation: \(error.localizedDescription)")
    }
}
