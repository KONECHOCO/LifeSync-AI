import SwiftUI
import SwiftData

/// Note vocali del giorno: registrazione, trascrizione sul dispositivo ed elenco.
struct VoiceNoteSection: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var recorder = VoiceNoteRecorder()
    @Query private var notes: [VoiceNote]

    private let readOnly: Bool

    init(dayKey: String, readOnly: Bool = false) {
        self.readOnly = readOnly
        _notes = Query(
            filter: #Predicate<VoiceNote> { $0.dayKey == dayKey },
            sort: \VoiceNote.date,
            order: .reverse
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("voice_title".localized, systemImage: "mic.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if !readOnly {
                    Button(action: toggleRecording) {
                        HStack(spacing: 6) {
                            if recorder.isTranscribing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: recorder.isRecording ? "stop.circle.fill" : "record.circle")
                            }
                            Text(recorder.isRecording ? "voice_stop".localized : "voice_record".localized)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background((recorder.isRecording ? Color.red : Color.pink).opacity(0.25))
                        .foregroundColor(recorder.isRecording ? .red : .pink)
                        .cornerRadius(10)
                    }
                    .disabled(recorder.isTranscribing)
                }
            }

            if !readOnly {
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(recorder.errorKey == nil ? .gray : .orange)
            }

            if notes.isEmpty {
                if readOnly {
                    Text("voice_empty".localized)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.cyan)
                        Text(note.text)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .contextMenu {
                        if !readOnly {
                            Button(role: .destructive) {
                                modelContext.delete(note)
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

    private var statusText: String {
        if let key = recorder.errorKey {
            return key.localized
        }
        if recorder.isTranscribing {
            return "voice_transcribing".localized
        }
        return "voice_desc".localized
    }

    private func toggleRecording() {
        recorder.toggle { text, duration in
            let now = Date()
            let note = VoiceNote(date: now, dayKey: DailyLogStore.key(for: now), text: text, duration: duration)
            modelContext.insert(note)
            try? modelContext.save()

            TimelineStore.add(
                id: "voice-\(note.id)",
                date: now,
                kind: "voice",
                title: "voice_title".localized,
                detail: text,
                in: modelContext
            )
        }
    }
}
