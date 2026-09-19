import SwiftUI
import SwiftData

/// Timeline degli eventi di un giorno: visite, attività rilevate, eventi manuali, note vocali.
struct TimelineSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [TimelineEvent]

    private let readOnly: Bool

    init(dayKey: String, readOnly: Bool = false) {
        self.readOnly = readOnly
        _events = Query(
            filter: #Predicate<TimelineEvent> { $0.dayKey == dayKey },
            sort: \TimelineEvent.date,
            order: .reverse
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("tl_title".localized, systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if !readOnly {
                    Menu {
                        Button("tl_office".localized) { addManual("tl_office") }
                        Button("tl_gym".localized) { addManual("tl_gym") }
                        Button("tl_home".localized) { addManual("tl_home") }
                        Button("tl_call".localized) { addManual("tl_call") }
                        Button("tl_lunch".localized) { addManual("tl_lunch") }
                    } label: {
                        Label("tl_add".localized, systemImage: "plus")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.cyan.opacity(0.18))
                            .foregroundColor(.cyan)
                            .cornerRadius(10)
                    }
                }
            }

            if events.isEmpty {
                Text("tl_empty".localized)
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(events.prefix(readOnly ? 100 : 12)) { event in
                    TimelineRow(event: event)
                        .contextMenu {
                            if !readOnly {
                                Button(role: .destructive) {
                                    modelContext.delete(event)
                                    try? modelContext.save()
                                } label: {
                                    Label("tl_delete".localized, systemImage: "trash")
                                }
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
    }

    private func addManual(_ key: String) {
        TimelineStore.add(
            date: Date(),
            kind: "manual",
            title: key.localized,
            detail: "tl_manual".localized,
            in: modelContext
        )
    }
}

private struct TimelineRow: View {
    let event: TimelineEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(event.date.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.cyan)
                .frame(width: 48, alignment: .leading)

            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                if !event.detail.isEmpty {
                    Text(event.detail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
    }

    private var iconName: String {
        switch event.kind {
        case "visit": return "mappin.circle.fill"
        case "activity": return "figure.walk"
        case "voice": return "mic.fill"
        case "call": return "phone.fill"
        case "message": return "message.fill"
        default: return "square.and.pencil"
        }
    }

    private var iconColor: Color {
        switch event.kind {
        case "visit": return .purple
        case "activity": return .cyan
        case "voice": return .pink
        case "call": return .green
        case "message": return .blue
        default: return .orange
        }
    }
}
