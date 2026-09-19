import Foundation
import CallKit
import SwiftData

/// Rileva inizio e fine delle chiamate (telefono e app che usano CallKit, come WhatsApp o Telegram).
/// iOS non fornisce numeri né contatti: si registrano solo direzione, orario e durata.
/// Funziona finché l'app è in esecuzione (anche in background con il monitoraggio dei luoghi attivo).
final class CallObserver: NSObject, CXCallObserverDelegate {
    static let shared = CallObserver()

    private let observer = CXCallObserver()
    private var startedAt: [UUID: Date] = [:]
    private var connectedAt: [UUID: Date] = [:]

    func start() {
        observer.setDelegate(self, queue: .main)
    }

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        let id = call.uuid

        if startedAt[id] == nil {
            startedAt[id] = Date()
        }
        if call.hasConnected && connectedAt[id] == nil {
            connectedAt[id] = Date()
        }
        guard call.hasEnded else { return }

        let start = startedAt.removeValue(forKey: id) ?? Date()
        let connected = connectedAt.removeValue(forKey: id)

        let titleKey: String
        var detail = ""
        if let connected = connected {
            titleKey = call.isOutgoing ? "tl_call_out" : "tl_call_in"
            let minutes = max(1, Int(Date().timeIntervalSince(connected) / 60))
            detail = String(format: "tl_duration_min".localized, minutes)
        } else if call.isOutgoing {
            return
        } else {
            titleKey = "tl_call_missed"
        }

        let context = ModelContext(LocalStore.container)
        TimelineStore.add(
            id: "call-\(id.uuidString)",
            date: start,
            kind: "call",
            title: titleKey.localized,
            detail: detail,
            in: context
        )
    }
}
