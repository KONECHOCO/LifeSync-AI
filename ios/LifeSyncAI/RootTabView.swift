import SwiftUI

/// Navigazione principale dell'app, con il banner AdMob in fondo per gli utenti free.
struct RootTabView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var ads = AdMobManager.shared
    @State private var selectedTab = 0

    private let bannerSize = AdBannerView.anchoredSize()

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem { Label("tab_today".localized, systemImage: "house.fill") }
                    .tag(0)

                HistoryView()
                    .tabItem { Label("tab_history".localized, systemImage: "clock.arrow.circlepath") }
                    .tag(1)

                StatsView()
                    .tabItem { Label("tab_stats".localized, systemImage: "chart.bar.fill") }
                    .tag(2)

                ProView()
                    .tabItem { Label("tab_pro".localized, systemImage: "crown.fill") }
                    .tag(3)

                SettingsView()
                    .tabItem { Label("tab_settings".localized, systemImage: "gearshape.fill") }
                    .tag(4)
            }
            .tint(.cyan)
            .onChange(of: selectedTab) { _, _ in
                ads.registerAction()
            }

            if ads.adsReady && !purchaseManager.isPro {
                AdBannerView(unitID: ads.bannerUnitID, adSize: bannerSize)
                    .frame(width: bannerSize.size.width, height: bannerSize.size.height)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 9/255, green: 13/255, blue: 22/255))
                    .id(ads.bannerUnitID)
            }
        }
        .background(Color(red: 9/255, green: 13/255, blue: 22/255).ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
