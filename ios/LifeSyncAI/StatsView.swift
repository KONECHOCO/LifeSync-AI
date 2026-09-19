import SwiftUI
import SwiftData
import Charts

/// Statistiche degli ultimi 7 giorni salvati.
struct StatsView: View {
    @Query(sort: \DailyBackupLog.dateString, order: .reverse) private var logs: [DailyBackupLog]

    private var lastSeven: [DailyBackupLog] {
        Array(logs.prefix(7).reversed())
    }

    private var averageSteps: Int {
        guard !lastSeven.isEmpty else { return 0 }
        return lastSeven.map(\.stepsCount).reduce(0, +) / lastSeven.count
    }

    private var bestDay: DailyBackupLog? {
        lastSeven.max(by: { $0.stepsCount < $1.stepsCount })
    }

    private var totalPlaces: Int {
        lastSeven.map(\.placesVisitedCount).reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 9/255, green: 13/255, blue: 22/255).ignoresSafeArea()

                if lastSeven.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 44))
                            .foregroundColor(.cyan)
                        Text("stats_no_data".localized)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("stats_last7".localized)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Chart(lastSeven) { log in
                                    BarMark(
                                        x: .value("day", shortDay(log.dateString)),
                                        y: .value("steps", log.stepsCount)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(colors: [.cyan, .purple], startPoint: .bottom, endPoint: .top)
                                    )
                                    .cornerRadius(4)
                                }
                                .frame(height: 220)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)

                            HStack(spacing: 12) {
                                MetricCardView(
                                    title: "stats_average".localized,
                                    value: "\(averageSteps)",
                                    icon: "figure.walk",
                                    color: .cyan
                                )
                                MetricCardView(
                                    title: "stats_total_places".localized,
                                    value: "\(totalPlaces)",
                                    icon: "mappin.circle.fill",
                                    color: .purple
                                )
                            }

                            if let best = bestDay {
                                HStack {
                                    Label("stats_best_day".localized, systemImage: "trophy.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                    Spacer()
                                    Text("\(formattedDay(best.dateString)) · \(best.stepsCount)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("stats_title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func shortDay(_ key: String) -> String {
        guard let date = DailyLogStore.date(from: key) else { return key }
        return date.formatted(.dateTime.weekday(.abbreviated))
    }
}
