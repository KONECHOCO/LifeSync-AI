import Foundation
import SwiftData

/// Evento della timeline giornaliera (visita, attività, evento manuale, nota vocale).
@Model
final class TimelineEvent {
    @Attribute(.unique) var id: String
    var date: Date
    var dayKey: String
    var kind: String
    var title: String
    var detail: String

    init(id: String, date: Date, dayKey: String, kind: String, title: String, detail: String) {
        self.id = id
        self.date = date
        self.dayKey = dayKey
        self.kind = kind
        self.title = title
        self.detail = detail
    }
}

/// Nota vocale trascritta sul dispositivo (l'audio non viene conservato).
@Model
final class VoiceNote {
    @Attribute(.unique) var id: String
    var date: Date
    var dayKey: String
    var text: String
    var duration: Double

    init(id: String = UUID().uuidString, date: Date, dayKey: String, text: String, duration: Double) {
        self.id = id
        self.date = date
        self.dayKey = dayKey
        self.text = text
        self.duration = duration
    }
}

/// Contenitore SwiftData condiviso: serve anche quando iOS avvia l'app in background per una visita.
enum LocalStore {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: DailyBackupLog.self, TimelineEvent.self, VoiceNote.self)
        } catch {
            fatalError("Impossibile creare il database locale: \(error)")
        }
    }()
}

enum TimelineStore {
    /// Inserisce o aggiorna un evento. Con lo stesso `id` l'evento viene aggiornato, non duplicato.
    static func add(
        id: String = UUID().uuidString,
        date: Date,
        kind: String,
        title: String,
        detail: String,
        in context: ModelContext
    ) {
        var descriptor = FetchDescriptor<TimelineEvent>(
            predicate: #Predicate<TimelineEvent> { $0.id == id }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            existing.title = title
            existing.detail = detail
            existing.date = date
        } else {
            let event = TimelineEvent(
                id: id,
                date: date,
                dayKey: DailyLogStore.key(for: date),
                kind: kind,
                title: title,
                detail: detail
            )
            context.insert(event)
        }
        try? context.save()
    }
}
