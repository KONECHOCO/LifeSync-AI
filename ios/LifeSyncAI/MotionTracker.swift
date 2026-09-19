import Foundation
import CoreMotion
import Combine

/// Tratto continuo di una stessa attività (still, walking, running, driving, cycling).
struct ActivitySegment {
    let category: String
    let start: Date
    let end: Date

    var duration: TimeInterval { end.timeIntervalSince(start) }
}

/// Tracker di movimento e conteggio passi tramite chip hardware integrato (CMPedometer)
final class MotionTracker: ObservableObject {

    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()

    @Published var stepsToday: Int = 0
    @Published var distanceMeters: Double = 0.0
    @Published var currentActivity: String = "act_still".localized

    func startTracking() {
        guard CMPedometer.isStepCountingAvailable() else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        // Recupera ed aggiorna i passi tramite l'hardware a basso consumo
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async {
                self?.stepsToday = data.numberOfSteps.intValue
                self?.distanceMeters = data.distance?.doubleValue ?? 0.0

                DailyLogAggregator.shared.updateSteps(data.numberOfSteps.intValue)
            }
        }

        // Rileva lo stato di movimento (Camminata, Corsa, In Veicolo)
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let activity = activity else { return }

                if activity.running {
                    self?.currentActivity = "act_running".localized
                } else if activity.walking {
                    self?.currentActivity = "act_walking".localized
                } else if activity.automotive {
                    self?.currentActivity = "act_driving".localized
                } else if activity.cycling {
                    self?.currentActivity = "act_cycling".localized
                } else {
                    self?.currentActivity = "act_still".localized
                }
            }
        }
    }

    /// Ricostruisce i tratti di attività di oggi dallo storico di CoreMotion.
    func loadTodaySegments(completion: @escaping ([ActivitySegment]) -> Void) {
        guard CMMotionActivityManager.isActivityAvailable() else {
            completion([])
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let now = Date()

        activityManager.queryActivityStarting(from: startOfDay, to: now, to: .main) { activities, _ in
            guard let activities = activities, !activities.isEmpty else {
                completion([])
                return
            }

            var segments: [ActivitySegment] = []
            var currentCategory: String?
            var currentStart = startOfDay

            for activity in activities where activity.confidence != .low {
                guard let category = MotionTracker.category(for: activity) else { continue }
                if category != currentCategory {
                    if let previous = currentCategory {
                        segments.append(ActivitySegment(category: previous, start: currentStart, end: activity.startDate))
                    }
                    currentCategory = category
                    currentStart = activity.startDate
                }
            }
            if let last = currentCategory {
                segments.append(ActivitySegment(category: last, start: currentStart, end: now))
            }
            completion(segments)
        }
    }

    private static func category(for activity: CMMotionActivity) -> String? {
        if activity.running { return "running" }
        if activity.cycling { return "cycling" }
        if activity.automotive { return "driving" }
        if activity.walking { return "walking" }
        if activity.stationary { return "still" }
        return nil
    }

    /// Legge dal pedometro i passi dei giorni precedenti (iOS ne conserva circa 7).
    func backfillPastDays(_ days: Int, completion: @escaping ([(String, Int)]) -> Void) {
        guard CMPedometer.isStepCountingAvailable(), days > 0 else {
            completion([])
            return
        }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        var results: [(String, Int)] = []
        let lock = NSLock()
        let group = DispatchGroup()

        for offset in 1...min(days, 6) {
            guard let start = calendar.date(byAdding: .day, value: -offset, to: startOfToday),
                  let end = calendar.date(byAdding: .day, value: 1, to: start) else { continue }
            let dayKey = DailyLogStore.key(for: start)
            group.enter()
            pedometer.queryPedometerData(from: start, to: end) { data, _ in
                if let data = data {
                    lock.lock()
                    results.append((dayKey, data.numberOfSteps.intValue))
                    lock.unlock()
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(results)
        }
    }
}
