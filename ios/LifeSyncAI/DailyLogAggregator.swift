import Foundation
import SwiftData

/// Modello SwiftData per la memorizzazione cifrata dei backup giornalieri dell'utente
@Model
final class DailyBackupLog {
    @Attribute(.unique) var id: String
    var dateString: String
    var stepsCount: Int
    var placesVisitedCount: Int
    var placesList: [String]
    var aiGeneratedSummary: String?
    var createdAt: Date
    
    init(id: String = UUID().uuidString, dateString: String, stepsCount: Int, placesVisitedCount: Int, placesList: [String], aiGeneratedSummary: String? = nil) {
        self.id = id
        self.dateString = dateString
        self.stepsCount = stepsCount
        self.placesVisitedCount = placesVisitedCount
        self.placesList = placesList
        self.aiGeneratedSummary = aiGeneratedSummary
        self.createdAt = Date()
    }
}

/// Singleton centralizzato per l'aggregazione dei dati giornalieri di movimento
final class DailyLogAggregator {
    static let shared = DailyLogAggregator()
    
    private var visitedPlaces: [String] = []
    private var currentStepsCount: Int = 0
    
    private init() {}
    
    func recordLocationEvent(latitude: Double, longitude: Double, date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeStr = formatter.string(from: date)
        
        let placeEntry = "[\(timeStr)] Posizione: \(String(format: "%.3f", latitude)), \(String(format: "%.3f", longitude))"
        visitedPlaces.append(placeEntry)
    }
    
    func updateSteps(_ steps: Int) {
        self.currentStepsCount = steps
    }
    
    /// Genera una stringa JSON compatta ed ottimizzata per l'invio all'AI
    func buildCompactJSONPayload() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        let payload: [String: Any] = [
            "date": todayStr,
            "steps": currentStepsCount,
            "places_count": visitedPlaces.count,
            "places": visitedPlaces
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
}
