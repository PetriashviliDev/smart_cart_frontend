//
//  AudioRecordingViewModel.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class AudioRecordingViewModel: BaseViewModel {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var recordingURL: URL?
    @Published var isProcessing = false
    
    private let audioService = AudioRecordingService()
    private let modelContext: ModelContext
    private let notificationService = NotificationService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        setupAudioServiceObservers()
    }
    
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var canProcessRecording: Bool {
        recordingURL != nil && !isRecording && !isProcessing
    }
    
    func startRecording() {
        audioService.startRecording()
    }
    
    func stopRecording() {
        audioService.stopRecording()
    }
    
    func processRecording() {
        guard canProcessRecording else { return }
        
        isProcessing = true
        
        Task {
            do {
                let reminders = try await audioService.processRecording()
                
                for reminder in reminders {
                    modelContext.insert(reminder)
                    
                    Task {
                        notificationService.scheduleNotification(for: reminder)
                    }
                }
                
                try modelContext.save()
                isProcessing = false
            } catch {
                isProcessing = false
                handleError(error)
            }
        }
    }
    
    func resetRecording() {
        audioService.resetRecording()
        recordingDuration = 0
        recordingURL = nil
        clearError()
    }
    
    private func setupAudioServiceObservers() {
        audioService.$isRecording
            .assign(to: &$isRecording)
        
        audioService.$recordingDuration
            .assign(to: &$recordingDuration)
        
        audioService.$recordingURL
            .assign(to: &$recordingURL)
    }
}
