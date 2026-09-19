import Foundation
import SwiftData

/// Persistenza dei log giornalieri (SwiftData) e utilità di export.
enum DailyLogStore {

    static func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func date(from key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }

    static func fetch(_ dateKey: String, in context: ModelContext) -> DailyBackupLog? {
        var descriptor = FetchDescriptor<DailyBackupLog>(
            predicate: #Predicate<DailyBackupLog> { $0.dateString == dateKey }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// Crea o aggiorna il log del giorno. I luoghi vengono uniti a quelli già salvati.
    @discardableResult
    static func upsert(
        dateString dateKey: String,
        steps: Int?,
        places: [String]?,
        summary: String?,
        in context: ModelContext
    ) -> DailyBackupLog {
        let log: DailyBackupLog
        if let existing = fetch(dateKey, in: context) {
            log = existing
        } else {
            log = DailyBackupLog(dateString: dateKey, stepsCount: 0, placesVisitedCount: 0, placesList: [])
            context.insert(log)
        }

        if let steps = steps {
            log.stepsCount = max(steps, 0)
        }
        if let places = places {
            let merged = log.placesList + places.filter { !log.placesList.contains($0) }
            log.placesList = merged
            log.placesVisitedCount = merged.count
        }
        if let summary = summary {
            log.aiGeneratedSummary = summary
        }
        try? context.save()
        return log
    }

    /// Media passi degli ultimi 7 giorni salvati, escluso oggi.
    static func averageSteps(excluding todayKey: String, in context: ModelContext) -> Int? {
        var descriptor = FetchDescriptor<DailyBackupLog>(
            sortBy: [SortDescriptor(\.dateString, order: .reverse)]
        )
        descriptor.fetchLimit = 8
        guard let logs = try? context.fetch(descriptor) else { return nil }
        let previous = logs.filter { $0.dateString != todayKey && $0.stepsCount > 0 }.prefix(7)
        guard !previous.isEmpty else { return nil }
        return previous.map(\.stepsCount).reduce(0, +) / previous.count
    }

    static func notesCount(for dateKey: String, in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<VoiceNote>(
            predicate: #Predicate<VoiceNote> { $0.dayKey == dateKey }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    /// Scrive tutti i dati in un file JSON temporaneo da condividere.
    static func exportJSON(in context: ModelContext) -> URL? {
        let dayDescriptor = FetchDescriptor<DailyBackupLog>(sortBy: [SortDescriptor(\.dateString)])
        let eventDescriptor = FetchDescriptor<TimelineEvent>(sortBy: [SortDescriptor(\.date)])
        let noteDescriptor = FetchDescriptor<VoiceNote>(sortBy: [SortDescriptor(\.date)])
        guard let logs = try? context.fetch(dayDescriptor) else { return nil }
        let events = (try? context.fetch(eventDescriptor)) ?? []
        let notes = (try? context.fetch(noteDescriptor)) ?? []
        let iso = ISO8601DateFormatter()

        let days: [[String: Any]] = logs.map { log in
            [
                "date": log.dateString,
                "steps": log.stepsCount,
                "places": log.placesList,
                "summary": log.aiGeneratedSummary ?? ""
            ]
        }
        let timeline: [[String: Any]] = events.map { event in
            [
                "time": iso.string(from: event.date),
                "type": event.kind,
                "title": event.title,
                "detail": event.detail
            ]
        }
        let voiceNotes: [[String: Any]] = notes.map { note in
            [
                "time": iso.string(from: note.date),
                "seconds": Int(note.duration),
                "text": note.text
            ]
        }
        let root: [String: Any] = ["days": days, "timeline": timeline, "voice_notes": voiceNotes]

        guard let data = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("LifeSync-backup-\(key(for: Date())).json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
