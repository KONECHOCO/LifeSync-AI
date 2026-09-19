import SwiftUI
import SwiftData

/// Impostazioni: notifica serale, dati locali e informazioni.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("nightlyEnabled") private var nightlyEnabled = true
    @AppStorage("nightlyMinutes") private var nightlyMinutes = 23 * 60

    @State private var showingDeleteConfirm = false
    @State private var testSent = false

    private let privacyURL = URL(string: "https://github.com/KONECHOCO/LifeSync-AI/blob/main/PRIVACY.md")
    private let supportURL = URL(string: "https://github.com/KONECHOCO/LifeSync-AI")

    var body: some View {
        NavigationStack {
            Form {
                Section("set_notifications".localized) {
                    Toggle("set_notif_toggle".localized, isOn: $nightlyEnabled)
                        .onChange(of: nightlyEnabled) { _, _ in reschedule() }

                    if nightlyEnabled {
                        DatePicker("set_notif_time".localized, selection: timeBinding, displayedComponents: .hourAndMinute)
                    }

                    Button("set_notif_test".localized) {
                        AISummarizerService.shared.sendTestNotification()
                        testSent = true
                    }
                    if testSent {
                        Text("set_notif_test_sent".localized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section("set_auto_title".localized) {
                    Text("set_auto_body".localized)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    if let shortcutsURL = URL(string: "shortcuts://") {
                        Link("set_auto_open".localized, destination: shortcutsURL)
                    }
                }

                Section("set_data".localized) {
                    Button("set_delete".localized, role: .destructive) {
                        showingDeleteConfirm = true
                    }
                }

                Section("set_about".localized) {
                    if let privacyURL = privacyURL {
                        Link("set_privacy".localized, destination: privacyURL)
                    }
                    if let supportURL = supportURL {
                        Link("set_support".localized, destination: supportURL)
                    }
                    HStack {
                        Text("set_version".localized)
                        Spacer()
                        Text(versionText)
                            .foregroundColor(.gray)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 9/255, green: 13/255, blue: 22/255).ignoresSafeArea())
            .navigationTitle("tab_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("set_delete_confirm".localized, isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("set_delete".localized, role: .destructive) { deleteAllData() }
                Button("set_cancel".localized, role: .cancel) { }
            } message: {
                Text("set_delete_msg".localized)
            }
        }
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: nightlyMinutes / 60,
                    minute: nightlyMinutes % 60,
                    second: 0,
                    of: Date()
                ) ?? Date()
            },
            set: { newValue in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                nightlyMinutes = (parts.hour ?? 23) * 60 + (parts.minute ?? 0)
                reschedule()
            }
        )
    }

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }

    private func reschedule() {
        AISummarizerService.shared.scheduleDailyNightlyNotification(
            enabled: nightlyEnabled,
            hour: nightlyMinutes / 60,
            minute: nightlyMinutes % 60
        )
    }

    private func deleteAllData() {
        try? modelContext.delete(model: DailyBackupLog.self)
        try? modelContext.delete(model: TimelineEvent.self)
        try? modelContext.delete(model: VoiceNote.self)
        try? modelContext.save()
    }
}
