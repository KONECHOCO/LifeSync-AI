import SwiftUI

/// Mostra il video di apertura, poi l'app principale.
struct RootContainerView: View {
    @State private var showIntro = true

    var body: some View {
        if showIntro {
            IntroVideoView(onFinished: {
                withAnimation(.easeOut(duration: 0.35)) {
                    showIntro = false
                }
            })
            .transition(.opacity)
        } else {
            RootTabView()
                .transition(.opacity)
        }
    }
}
