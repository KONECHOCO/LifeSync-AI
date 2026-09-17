import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var motionTracker = MotionTracker()
    
    @State private var aiSummaryText: String = "Il tuo riepilogo automatico delle ore 23:00 comparirà qui."
    @State private var isGenerating: Bool = false
    @State private var showingBackupAlert: Bool = false
    
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
                                Text("Oggi, 17 Settembre")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                                Text("LifeSync AI Log")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Attivo")
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
                                title: "Passi Oggi",
                                value: "\(motionTracker.stepsToday)",
                                icon: "shoeprints.fill",
                                color: .cyan
                            )
                            
                            MetricCardView(
                                title: "Luoghi Visitati",
                                value: "\(locationManager.visitsCountToday)",
                                icon: "mappin.circle.fill",
                                color: .purple
                            )
                        }
                        
                        // Activity Status
                        HStack {
                            Label("Attività Rilevata:", systemImage: "figure.walk")
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
                                Label("Riepilogo Assistente AI", systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                
                                Spacer()
                                
                                Button(action: generateAISummary) {
                                    HStack(spacing: 5) {
                                        if isGenerating {
                                            ProgressView()
                                                .tint(.black)
                                        } else {
                                            Image(systemName: "arrow.clockwise")
                                        }
                                        Text(isGenerating ? "Generazione..." : "Genera Ora")
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
                                Label("Stato Backup Giornaliero", systemImage: "lock.shield.fill")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Spacer()
                                Text("AES-256")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(6)
                            }
                            Text("I dati dei sensori di movimento e le posizioni sono memorizzati esclusivamente in locale e nel tuo backup cifrato iCloud.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: { showingBackupAlert = true }) {
                                HStack {
                                    Image(systemName: "arrow.down.doc")
                                    Text("Esporta Log & Backup")
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
            .alert("Backup Completo", isPresented: $showingBackupAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Il tuo backup giornaliero è archiviato in locale con successo.")
            }
        }
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
