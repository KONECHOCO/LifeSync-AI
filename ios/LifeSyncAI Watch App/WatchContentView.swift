import SwiftUI

struct WatchContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("watch_title".localized)
                    .font(.headline)
                    .foregroundColor(.cyan)

                HStack(spacing: 10) {
                    statTile(icon: "shoeprints.fill", value: "\(connectivity.steps)", label: "watch_steps".localized, color: .cyan)
                    statTile(icon: "mappin.circle.fill", value: "\(connectivity.places)", label: "watch_places".localized, color: .purple)
                }

                statTile(icon: "bed.double.fill", value: formatDuration(connectivity.restSeconds), label: "watch_rest".localized, color: .orange, fullWidth: true)

                VStack(alignment: .leading, spacing: 4) {
                    Label("watch_summary_title".localized, systemImage: "sparkles")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(connectivity.summary)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)

                Button(action: { connectivity.requestRefresh() }) {
                    Label("watch_refresh".localized, systemImage: "arrow.clockwise")
                        .font(.caption2)
                }
                .buttonStyle(.bordered)
                .tint(.cyan)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 4)
        }
        .onAppear { connectivity.requestRefresh() }
    }

    private func statTile(icon: String, value: String, label: String, color: Color, fullWidth: Bool = false) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .frame(width: fullWidth ? nil : 70)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.08))
        .cornerRadius(10)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}
