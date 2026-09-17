import SwiftUI
import SwiftData

@main
struct LifeSyncApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DailyBackupLog.self)
    }
}
