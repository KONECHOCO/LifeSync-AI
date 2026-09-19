import SwiftUI

/// Navigazione principale dell'app.
struct RootTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("tab_today".localized, systemImage: "house.fill") }

            HistoryView()
                .tabItem { Label("tab_history".localized, systemImage: "clock.arrow.circlepath") }

            StatsView()
                .tabItem { Label("tab_stats".localized, systemImage: "chart.bar.fill") }

            ProView()
                .tabItem { Label("tab_pro".localized, systemImage: "crown.fill") }
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }
}
