import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var motionTracker = MotionTracker()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var unityAdsManager = UnityAdsManager.shared
    
    @State private var aiSummaryText: String = "Il tuo riepilogo automatico delle ore 23:00 comparirà qui."
    @State private var isGenerating: Bool = false
    @State private var showingBackupAlert: Bool = false
    @State private var showingPaywall: Bool = false
    
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
                                value: "\(locationManager.visitsCountToday)",
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
                            Text("I dati dei sensori di movimento e le posizioni sono memorizzati sul dispositivo per creare il tuo riepilogo giornaliero.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: exportBackup) {
                                HStack {
                                    Image(systemName: "arrow.down.doc")
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
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .alert("backup_complete".localized, isPresented: $showingBackupAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("backup_complete_message".localized)
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
        if !subscriptionManager.isSubscribed, let presenter = UIViewController.topMostViewController() {
            unityAdsManager.showInterstitialAd(from: presenter)
        }
        showingBackupAlert = true
    }
    
    private func generateAISummary() {
        isGenerating = true
        let payload = DailyLogAggregator.shared.buildCompactJSONPayload()
        
        AISummarizerService.shared.fetchDailySummary(jsonPayload: payload) { result in
            DispatchQueue.main.async {
                isGenerating = false
                if case .success(let text) = result {
                    self.aiSummaryText = text
                }
            }
        }
    }
}

private extension UIViewController {
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
