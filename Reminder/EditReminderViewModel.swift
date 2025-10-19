//
//  EditReminderViewModel.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class EditReminderViewModel: BaseViewModel {
    @Published var text: String
    @Published var selectedDate: Date
    @Published var selectedPriority: Priority
    @Published var showingDatePicker = false
    @Published var selectedTags: Set<String>
    
    let availableTags: [String] = ["Образование", "Медицина", "Работа", "Личное", "Покупки", "Прочее"]
    
    private let reminder: Reminder
    private let modelContext: ModelContext
    private let notificationService = NotificationService.shared
    
    init(reminder: Reminder, modelContext: ModelContext) {
        self.reminder = reminder
        self.modelContext = modelContext
        self.text = reminder.text
        self.selectedDate = reminder.date
        self.selectedPriority = reminder.priority
        self.selectedTags = Set(reminder.tags)
        super.init()
    }
    
    var isSaveEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func saveChanges() {
        guard isSaveEnabled else { return }
        
        isLoading = true
        
        reminder.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        reminder.date = selectedDate
        reminder.priority = selectedPriority
        reminder.tags = Array(selectedTags)
        
        Task {
            do {
                try modelContext.save()
                notificationService.cancelNotification(for: reminder)
                notificationService.scheduleNotification(for: reminder)
                isLoading = false
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
    
    func deleteReminder() {
        isLoading = true
        
        Task {
            notificationService.cancelNotification(for: reminder)
            modelContext.delete(reminder)
            
            do {
                try modelContext.save()
                isLoading = false
            } catch {
                isLoading = false
                handleError(error)
            }
        }
    }
}
