import SwiftUI

/// Mostra il video di apertura, poi l'app principale.
/// Subito dopo: consenso (GDPR + ATT) e video pubblicitario all'apertura per gli utenti free.
struct RootContainerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showIntro = true

    var body: some View {
        Group {
            if showIntro {
                IntroVideoView(onFinished: {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showIntro = false
                    }
                    Task {
                        await AdMobManager.shared.start()
                        await AdMobManager.shared.showAppOpenAtLaunch()
                    }
                })
                .transition(.opacity)
            } else {
                RootTabView()
                    .transition(.opacity)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                AdMobManager.shared.appDidEnterBackground()
            case .active:
                if !showIntro {
                    AdMobManager.shared.appDidBecomeActive()
                }
            default:
                break
            }
        }
    }
}
