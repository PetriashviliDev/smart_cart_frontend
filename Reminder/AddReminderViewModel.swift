//
//  AddReminderViewModel.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class AddReminderViewModel: BaseViewModel {
    @Published var text = ""
    @Published var selectedDate = Date()
    @Published var selectedPriority: Priority = .medium
    @Published var showingDatePicker = false
    @Published var selectedTags: Set<String> = []
    
    let availableTags: [String] = ["Образование", "Медицина", "Работа", "Личное", "Покупки", "Прочее"]
    
    private let modelContext: ModelContext
    private let notificationService = NotificationService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
    }
    
    var isSaveEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func saveReminder() {
        guard isSaveEnabled else { return }
        
        isLoading = true
        
        let reminder = Reminder(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            date: selectedDate,
            priority: selectedPriority,
            audioURL: nil,
            tags: Array(selectedTags)
        )
        
        modelContext.insert(reminder)
        
        Task {
            do {
                try modelContext.save()
                notificationService.scheduleNotification(for: reminder)
                isLoading = false
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
    
    func resetForm() {
        text = ""
        selectedDate = Date()
        selectedPriority = .medium
        showingDatePicker = false
        clearError()
    }
}
