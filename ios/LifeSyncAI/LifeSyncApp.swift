import SwiftUI
import SwiftData
import UserNotifications

@main
struct LifeSyncApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        // Se iOS avvia l'app in background per una visita, il monitoraggio riparte subito.
        LocationManager.shared.resumeIfAuthorized()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(LocalStore.container)
    }
}
