import Foundation
import AVFoundation
import Speech
import Combine

/// Registra una nota vocale e la trascrive interamente sul dispositivo (nessun audio esce dal telefono).
final class VoiceNoteRecorder: NSObject, ObservableObject {

    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var errorKey: String?

    private var recorder: AVAudioRecorder?
    private var fileURL: URL?
    private var startTime: Date?
    private var task: SFSpeechRecognitionTask?

    func toggle(onFinished: @escaping (String, TimeInterval) -> Void) {
        if isRecording {
            stopAndTranscribe(onFinished: onFinished)
        } else {
            requestPermissionsThenStart()
        }
    }

    // MARK: - Permessi

    private func requestPermissionsThenStart() {
        errorKey = nil
        AVAudioApplication.requestRecordPermission { [weak self] micGranted in
            SFSpeechRecognizer.requestAuthorization { speechStatus in
                DispatchQueue.main.async {
                    guard micGranted, speechStatus == .authorized else {
                        self?.errorKey = "voice_err_perm"
                        return
                    }
                    self?.startRecording()
                }
            }
        }
    }

    // MARK: - Registrazione

    private func startRecording() {
        guard let recognizer = SFSpeechRecognizer(locale: Locale.current), recognizer.supportsOnDeviceRecognition else {
            errorKey = "voice_err_unsupported"
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("voice-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]
            let newRecorder = try AVAudioRecorder(url: url, settings: settings)
            guard newRecorder.record() else {
                errorKey = "voice_err_generic"
                return
            }
            recorder = newRecorder
            fileURL = url
            startTime = Date()
            isRecording = true
        } catch {
            errorKey = "voice_err_generic"
        }
    }

    private func stopAndTranscribe(onFinished: @escaping (String, TimeInterval) -> Void) {
        recorder?.stop()
        recorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        let duration = Date().timeIntervalSince(startTime ?? Date())
        guard let url = fileURL else {
            errorKey = "voice_err_generic"
            return
        }
        fileURL = nil

        guard let recognizer = SFSpeechRecognizer(locale: Locale.current),
              recognizer.isAvailable,
              recognizer.supportsOnDeviceRecognition else {
            try? FileManager.default.removeItem(at: url)
            errorKey = "voice_err_unsupported"
            return
        }

        isTranscribing = true
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false

        var finished = false
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self, !finished else { return }

                if let result = result, result.isFinal {
                    finished = true
                    self.finish(url: url)
                    let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if text.isEmpty {
                        self.errorKey = "voice_err_empty"
                    } else {
                        onFinished(text, duration)
                    }
                } else if error != nil {
                    finished = true
                    self.finish(url: url)
                    self.errorKey = "voice_err_empty"
                }
            }
        }
    }

    private func finish(url: URL) {
        isTranscribing = false
        task = nil
        try? FileManager.default.removeItem(at: url)
    }
}
