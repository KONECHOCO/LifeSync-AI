import SwiftUI
import SwiftData

private let appBackground = Color(red: 9/255, green: 13/255, blue: 22/255)

/// Elenco dei giorni salvati con passi, luoghi e riepilogo.
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyBackupLog.dateString, order: .reverse) private var logs: [DailyBackupLog]

    var body: some View {
        NavigationStack {
            ZStack {
                appBackground.ignoresSafeArea()

                if logs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 44))
                            .foregroundColor(.cyan)
                        Text("history_empty".localized)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 32)
                    }
                } else {
                    List {
                        ForEach(logs) { log in
                            NavigationLink {
                                HistoryDetailView(log: log)
                            } label: {
                                HistoryRow(log: log)
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                        .onDelete(perform: delete)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("history_title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(logs[index])
        }
        try? modelContext.save()
    }
}

private struct HistoryRow: View {
    let log: DailyBackupLog

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formattedDay(log.dateString))
                .font(.headline)
                .foregroundColor(.white)
            HStack(spacing: 16) {
                Label(String(format: "history_steps".localized, log.stepsCount), systemImage: "shoeprints.fill")
                    .foregroundColor(.cyan)
                Label(String(format: "history_places".localized, log.placesVisitedCount), systemImage: "mappin.circle.fill")
                    .foregroundColor(.purple)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct HistoryDetailView: View {
    let log: DailyBackupLog

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        MetricCardView(
                            title: "steps_today".localized,
                            value: "\(log.stepsCount)",
                            icon: "shoeprints.fill",
                            color: .cyan
                        )
                        MetricCardView(
                            title: "visited_places".localized,
                            value: "\(log.placesVisitedCount)",
                            icon: "mappin.circle.fill",
                            color: .purple
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("detail_summary".localized, systemImage: "sparkles")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Text(summaryText)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("detail_places".localized, systemImage: "mappin.and.ellipse")
                            .font(.headline)
                            .foregroundColor(.purple)
                        if log.placesList.isEmpty {
                            Text("detail_no_places".localized)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(log.placesList, id: \.self) { place in
                                Text(place)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
                .padding()
            }
        }
        .navigationTitle(formattedDay(log.dateString))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryText: String {
        if let summary = log.aiGeneratedSummary, !summary.isEmpty {
            return summary
        }
        return "detail_no_summary".localized
    }
}

/// Converte "yyyy-MM-dd" in una data leggibile nella lingua dell'utente.
func formattedDay(_ key: String) -> String {
    guard let date = DailyLogStore.date(from: key) else { return key }
    return date.formatted(date: .abbreviated, time: .omitted)
}
