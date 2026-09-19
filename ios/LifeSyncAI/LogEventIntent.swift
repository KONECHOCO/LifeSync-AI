import Foundation
import AppIntents
import SwiftData

/// Azione per l'app Comandi: registra un evento nella timeline di LifeSync.
/// Permette di creare automazioni, per esempio "quando ricevo un messaggio, registra un evento".
struct LogEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Registra evento in LifeSync"
    static var description = IntentDescription("Aggiunge un evento alla timeline di oggi in LifeSync AI.")

    @Parameter(title: "Titolo", default: "Messaggio ricevuto")
    var eventTitle: String

    @Parameter(title: "Dettaglio", default: "")
    var eventDetail: String

    static var parameterSummary: some ParameterSummary {
        Summary("Registra \(\.$eventTitle)")
    }

    func perform() async throws -> some IntentResult {
        let context = ModelContext(LocalStore.container)
        TimelineStore.add(
            date: Date(),
            kind: "message",
            title: eventTitle,
            detail: eventDetail,
            in: context
        )
        return .result()
    }
}

struct LifeSyncShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogEventIntent(),
            phrases: ["Registra un evento in \(.applicationName)"],
            shortTitle: "Registra evento",
            systemImageName: "square.and.pencil"
        )
    }
}
