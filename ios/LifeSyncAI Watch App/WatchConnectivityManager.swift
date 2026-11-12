import Foundation
import WatchConnectivity

/// Lato Apple Watch del collegamento con l'app iPhone: riceve il riepilogo di oggi
/// (passi, luoghi, riposo, riepilogo AI) tramite WatchConnectivity.
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var steps: Int = 0
    @Published var places: Int = 0
    @Published var restSeconds: Int = 0
    @Published var summary: String = "watch_waiting".localized
    @Published var isPro: Bool = false
    @Published var lastUpdated: Date?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Chiede un aggiornamento immediato all'iPhone, se raggiungibile.
    func requestRefresh() {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        guard WCSession.default.isReachable else { return }

        WCSession.default.sendMessage([:], replyHandler: { [weak self] reply in
            DispatchQueue.main.async { self?.apply(context: reply) }
        }, errorHandler: nil)
    }

    private func apply(context: [String: Any]) {
        if let steps = context["steps"] as? Int { self.steps = steps }
        if let places = context["places"] as? Int { self.places = places }
        if let rest = context["restSeconds"] as? Int { self.restSeconds = rest }
        if let summary = context["summary"] as? String, !summary.isEmpty { self.summary = summary }
        if let isPro = context["isPro"] as? Bool { self.isPro = isPro }
        if let updatedAt = context["updatedAt"] as? TimeInterval {
            self.lastUpdated = Date(timeIntervalSince1970: updatedAt)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.apply(context: session.receivedApplicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.apply(context: applicationContext)
        }
    }
}
