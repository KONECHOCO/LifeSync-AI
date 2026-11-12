import SwiftUI
import AVFoundation
import AVKit

/// Video di apertura mostrato a ogni avvio dell'app (saltabile con un tocco).
struct IntroVideoView: View {
    let onFinished: () -> Void

    @State private var player: AVPlayer?
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            Color(red: 9/255, green: 13/255, blue: 22/255)
                .ignoresSafeArea()

            if let player {
                IntroPlayerLayerView(player: player)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: finish) {
                        Text("intro_skip".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear(perform: setupPlayer)
        .onTapGesture(perform: finish)
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "intro", withExtension: "mp4") else {
            finish()
            return
        }

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.isMuted = true
        self.player = newPlayer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            finish()
        }

        newPlayer.play()

        // Rete di sicurezza: se la riproduzione non parte o si blocca, non lasciare mai l'utente bloccato.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            finish()
        }
    }

    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        player?.pause()
        onFinished()
    }
}

/// Wrapper UIKit minimale per riprodurre il video a schermo intero senza controlli nativi.
private struct IntroPlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerContainerUIView {
        PlayerContainerUIView(player: player)
    }

    func updateUIView(_ uiView: PlayerContainerUIView, context: Context) {}
}

private final class PlayerContainerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
