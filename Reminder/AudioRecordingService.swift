//
//  AudioRecordingService.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioRecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var recordingURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var networkService = NetworkService.shared
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingURL = audioFilename
            startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
    }
    
    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.recordingDuration += 0.1
        }
    }
    
    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func processRecording() async throws -> [Reminder] {
        guard let url = recordingURL else {
            throw AudioError.noRecording
        }
        
        let audioData = try Data(contentsOf: url)
        let responses = try await networkService.processAudioRecording(audioData: audioData)
        
        return responses.map { response in
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: response.date) ?? Date()
            let priority = Priority(rawValue: response.priority) ?? .medium
            
            return Reminder(text: response.text, date: date, priority: priority, audioURL: url.absoluteString)
        }
    }
    
    func resetRecording() {
        recordingDuration = 0
        recordingURL = nil
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}

enum AudioError: Error {
    case noRecording
    case recordingFailed
}
