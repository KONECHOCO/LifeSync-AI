import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// Lato iPhone del collegamento con l'app Apple Watch: invia il riepilogo di oggi
/// (passi, luoghi, riepilogo AI) ogni volta che cambia, cosi l'orologio resta sincronizzato.
final class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()

    private override init() {
        super.init()
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        #endif
    }

    /// Invia lo stato aggiornato all'Apple Watch (se abbinato e raggiungibile).
    func sendTodaySnapshot(steps: Int, places: Int, restSeconds: Int, summary: String, isPro: Bool) {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

        let context: [String: Any] = [
            "steps": steps,
            "places": places,
            "restSeconds": restSeconds,
            "summary": summary,
            "isPro": isPro,
            "updatedAt": Date().timeIntervalSince1970
        ]
        try? WCSession.default.updateApplicationContext(context)
        #endif
    }
}

#if canImport(WatchConnectivity)
extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    /// Il Watch chiede un aggiornamento immediato (es. aperto dall'utente): rispondiamo con l'ultimo contesto noto.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        replyHandler(session.applicationContext)
    }
}
#endif
