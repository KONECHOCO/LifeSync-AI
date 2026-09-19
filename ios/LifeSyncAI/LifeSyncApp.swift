import SwiftUI
import SwiftData

@main
struct LifeSyncApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: DailyBackupLog.self)
    }
}
