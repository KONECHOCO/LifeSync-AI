import os

BASE = 'ios/LifeSyncAI/'


def read(name):
    with open(BASE + name, encoding='utf-8', newline='') as f:
        return f.read().replace('\r\n', '\n')


def write(name, text):
    with open(BASE + name, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def replace_once(text, old, new):
    assert old in text, 'missing: ' + old[:60]
    return text.replace(old, new, 1)


# ---------------- ContentView ----------------
s = read('ContentView.swift')
s = s.replace('@StateObject private var locationManager = LocationManager()', '@StateObject private var locationManager = LocationManager.shared')
s = replace_once(s, '    @State private var showingExportError: Bool = false\n',
                 '    @State private var showingExportError: Bool = false\n    @State private var restSeconds: Int = 0\n    @State private var activeSeconds: Int = 0\n    @State private var lastPersist: Date = .distantPast\n')

old = '''                            MetricCardView(
                                title: "visited_places".localized,
                                value: "\\(max(placesCount, locationManager.visitsCountToday))",
                                icon: "mappin.circle.fill",
                                color: .purple
                            )
                        }
'''
new = '''                            MetricCardView(
                                title: "visited_places".localized,
                                value: "\\(max(placesCount, locationManager.visitsCountToday))",
                                icon: "mappin.circle.fill",
                                color: .purple
                            )

                            MetricCardView(
                                title: "rest_label".localized,
                                value: formatDuration(restSeconds),
                                icon: "bed.double.fill",
                                color: .orange
                            )
                        }
'''
s = replace_once(s, old, new)

s = replace_once(s, '                        // AI Summary Section\n',
                 '''                        // Timeline & note vocali
                        TimelineSection(dayKey: DailyLogStore.key(for: Date()))
                        VoiceNoteSection(dayKey: DailyLogStore.key(for: Date()))

                        // AI Summary Section
''')

old = '''                AISummarizerService.shared.scheduleDailyNightlyNotification()
                loadToday()
                backfillHistory()
            }
'''
new = '''                AISummarizerService.shared.scheduleFromSettings()
                loadToday()
                backfillHistory()
                refreshActivity()
            }
            .refreshable {
                refreshActivity()
                persistToday(force: true)
            }
'''
s = replace_once(s, old, new)

old = '''                if newPhase == .background {
                    persistToday()
                }
'''
new = '''                if newPhase == .background {
                    persistToday(force: true)
                } else if newPhase == .active {
                    refreshActivity()
                }
'''
s = replace_once(s, old, new)

s = replace_once(s, '''    private func persistToday() {
        let key = DailyLogStore.key(for: Date())''', '''    private func persistToday(force: Bool = false) {
        if !force && Date().timeIntervalSince(lastPersist) < 15 { return }
        lastPersist = Date()
        let key = DailyLogStore.key(for: Date())''')

s = replace_once(s, '        persistToday()\n        if let url = DailyLogStore.exportJSON', '        persistToday(force: true)\n        if let url = DailyLogStore.exportJSON')
s = replace_once(s, '        isGenerating = true\n        persistToday()\n', '        isGenerating = true\n        persistToday(force: true)\n')

s = replace_once(s, '        let text = AISummarizerService.shared.makeDailySummary(steps: steps, places: places, averageSteps: average)', '''        let notesCount = DailyLogStore.notesCount(for: key, in: modelContext)
        let text = AISummarizerService.shared.makeDailySummary(
            steps: steps,
            places: places,
            averageSteps: average,
            activeMinutes: activeSeconds / 60,
            notes: notesCount
        )''')

old = '    // MARK: - Azioni\n'
new = '''    private func refreshActivity() {
        motionTracker.loadTodaySegments { segments in
            var rest = 0
            var active = 0
            for segment in segments {
                let seconds = Int(segment.duration)
                if segment.category == "still" {
                    rest += seconds
                } else {
                    active += seconds
                    if seconds >= 300 {
                        let start = segment.start
                        TimelineStore.add(
                            id: "act-\\(segment.category)-\\(Int(start.timeIntervalSince1970))",
                            date: start,
                            kind: "activity",
                            title: "act_\\(segment.category)".localized,
                            detail: String(format: "tl_duration_min".localized, seconds / 60),
                            in: modelContext
                        )
                    }
                }
            }
            restSeconds = rest
            activeSeconds = active
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return hours > 0 ? "\\(hours)h \\(minutes)m" : "\\(minutes)m"
    }

    // MARK: - Azioni
'''
s = replace_once(s, old, new)

s = replace_once(s, '''            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)''', '''            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)''')
write('ContentView.swift', s)

# ---------------- DailyLogStore ----------------
s = read('DailyLogStore.swift')
a = s.index('    /// Scrive tutti i log in un file JSON')
s = s[:a] + '''    static func notesCount(for dateKey: String, in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<VoiceNote>(
            predicate: #Predicate<VoiceNote> { $0.dayKey == dateKey }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    /// Scrive tutti i dati in un file JSON temporaneo da condividere.
    static func exportJSON(in context: ModelContext) -> URL? {
        let dayDescriptor = FetchDescriptor<DailyBackupLog>(sortBy: [SortDescriptor(\\.dateString)])
        let eventDescriptor = FetchDescriptor<TimelineEvent>(sortBy: [SortDescriptor(\\.date)])
        let noteDescriptor = FetchDescriptor<VoiceNote>(sortBy: [SortDescriptor(\\.date)])
        guard let logs = try? context.fetch(dayDescriptor) else { return nil }
        let events = (try? context.fetch(eventDescriptor)) ?? []
        let notes = (try? context.fetch(noteDescriptor)) ?? []
        let iso = ISO8601DateFormatter()

        let days: [[String: Any]] = logs.map { log in
            [
                "date": log.dateString,
                "steps": log.stepsCount,
                "places": log.placesList,
                "summary": log.aiGeneratedSummary ?? ""
            ]
        }
        let timeline: [[String: Any]] = events.map { event in
            [
                "time": iso.string(from: event.date),
                "type": event.kind,
                "title": event.title,
                "detail": event.detail
            ]
        }
        let voiceNotes: [[String: Any]] = notes.map { note in
            [
                "time": iso.string(from: note.date),
                "seconds": Int(note.duration),
                "text": note.text
            ]
        }
        let root: [String: Any] = ["days": days, "timeline": timeline, "voice_notes": voiceNotes]

        guard let data = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("LifeSync-backup-\\(key(for: Date())).json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
'''
write('DailyLogStore.swift', s)

# ---------------- App + tabs + history detail ----------------
write('LifeSyncApp.swift', '''import SwiftUI
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
''')

write('RootTabView.swift', '''import SwiftUI

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

            SettingsView()
                .tabItem { Label("tab_settings".localized, systemImage: "gearshape.fill") }
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }
}
''')

s = read('HistoryView.swift')
old = '''                    VStack(alignment: .leading, spacing: 8) {
                        Label("detail_places".localized, systemImage: "mappin.and.ellipse")'''
new = '''                    TimelineSection(dayKey: log.dateString, readOnly: true)
                    VoiceNoteSection(dayKey: log.dateString, readOnly: true)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("detail_places".localized, systemImage: "mappin.and.ellipse")'''
s = replace_once(s, old, new)
write('HistoryView.swift', s)

print('ok')
