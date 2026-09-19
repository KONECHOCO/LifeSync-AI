import SwiftUI
import SwiftData
import UIKit

/// Schermata "Oggi": passi, luoghi, riepilogo giornaliero ed export del backup.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var locationManager = LocationManager()
    @StateObject private var motionTracker = MotionTracker()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var unityAdsManager = UnityAdsManager.shared

    @State private var aiSummaryText: String = "ai_placeholder".localized
    @State private var isGenerating: Bool = false
    @State private var showingPaywall: Bool = false
    @State private var placesCount: Int = 0
    @State private var exportURL: URL?
    @State private var showingShare: Bool = false
    @State private var showingExportError: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 9/255, green: 13/255, blue: 22/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Header Card
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(todayTitle)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                                Text("app_title".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("active_status".localized)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(20)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)

                        // Metrics Grid
                        HStack(spacing: 12) {
                            MetricCardView(
                                title: "steps_today".localized,
                                value: "\(motionTracker.stepsToday)",
                                icon: "shoeprints.fill",
                                color: .cyan
                            )

                            MetricCardView(
                                title: "visited_places".localized,
                                value: "\(max(placesCount, locationManager.visitsCountToday))",
                                icon: "mappin.circle.fill",
                                color: .purple
                            )
                        }

                        // Activity Status
                        HStack {
                            Label("detected_activity".localized, systemImage: "figure.walk")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(motionTracker.currentActivity)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                        }
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)

                        // AI Summary Section
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("ai_summary".localized, systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundColor(.yellow)

                                Spacer()

                                Button(action: requestAISummaryAccess) {
                                    HStack(spacing: 5) {
                                        if isGenerating {
                                            ProgressView()
                                                .tint(.black)
                                        } else {
                                            Image(systemName: "arrow.clockwise")
                                        }
                                        Text(isGenerating ? "generating".localized : summaryButtonTitle)
                                    }
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(isGenerating)
                            }

                            Text(aiSummaryText)
                                .font(.subheadline)
                                .lineSpacing(5)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(20)

                        // Backup Status Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("daily_backup_status".localized, systemImage: "lock.shield.fill")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            Text("backup_desc".localized)
                                .font(.caption)
                                .foregroundColor(.gray)

                            Button(action: exportBackup) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("export_backup".localized)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.08))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(20)

                    }
                    .padding()
                }
            }
            .navigationTitle("LifeSync AI")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestPermissionsAndStart()
                motionTracker.startTracking()
                AISummarizerService.shared.scheduleDailyNightlyNotification()
                loadToday()
                backfillHistory()
            }
            .onChange(of: motionTracker.stepsToday) { _, _ in
                persistToday()
            }
            .onChange(of: locationManager.visitsCountToday) { _, _ in
                persistToday()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    persistToday()
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingShare) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("pw_error_title".localized, isPresented: $showingExportError) {
                Button("pw_ok".localized, role: .cancel) { }
            } message: {
                Text("export_error".localized)
            }
        }
    }

    private var summaryButtonTitle: String {
        subscriptionManager.isSubscribed ? "generate_now".localized : "watch_ad_unlock".localized
    }

    private var todayTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\("today_label".localized), \(formatter.string(from: Date()))"
    }

    // MARK: - Persistenza

    private func loadToday() {
        let key = DailyLogStore.key(for: Date())
        if let log = DailyLogStore.fetch(key, in: modelContext) {
            placesCount = log.placesVisitedCount
            if let summary = log.aiGeneratedSummary, !summary.isEmpty {
                aiSummaryText = summary
            }
        }
    }

    private func persistToday() {
        let key = DailyLogStore.key(for: Date())
        let log = DailyLogStore.upsert(
            dateString: key,
            steps: motionTracker.stepsToday,
            places: DailyLogAggregator.shared.placesSnapshot,
            summary: nil,
            in: modelContext
        )
        placesCount = log.placesVisitedCount
    }

    private func backfillHistory() {
        motionTracker.backfillPastDays(6) { results in
            for (dayKey, steps) in results where steps > 0 {
                DailyLogStore.upsert(dateString: dayKey, steps: steps, places: nil, summary: nil, in: modelContext)
            }
        }
    }

    // MARK: - Azioni

    private func requestAISummaryAccess() {
        guard !subscriptionManager.isSubscribed else {
            generateAISummary()
            return
        }

        guard let presenter = UIViewController.topMostViewController() else {
            showingPaywall = true
            return
        }

        unityAdsManager.showRewardedAd(from: presenter) { didEarnReward in
            DispatchQueue.main.async {
                if didEarnReward {
                    generateAISummary()
                } else {
                    showingPaywall = true
                }
            }
        }
    }

    private func exportBackup() {
        persistToday()
        if let url = DailyLogStore.exportJSON(in: modelContext) {
            exportURL = url
            showingShare = true
        } else {
            showingExportError = true
        }
    }

    private func generateAISummary() {
        isGenerating = true
        persistToday()

        let key = DailyLogStore.key(for: Date())
        let steps = motionTracker.stepsToday
        let places = max(placesCount, locationManager.visitsCountToday)
        let average = DailyLogStore.averageSteps(excluding: key, in: modelContext)
        let text = AISummarizerService.shared.makeDailySummary(steps: steps, places: places, averageSteps: average)

        aiSummaryText = text
        DailyLogStore.upsert(dateString: key, steps: nil, places: nil, summary: text, in: modelContext)
        isGenerating = false
    }
}

extension UIViewController {
    static func topMostViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let navigation = base as? UINavigationController {
            return topMostViewController(base: navigation.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}

/// Foglio di condivisione di sistema per il file di backup.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Subview per le tessere delle metriche
struct MetricCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
