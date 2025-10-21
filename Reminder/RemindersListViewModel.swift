//
//  RemindersListViewModel.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class RemindersListViewModel: BaseViewModel {
    @Published var reminders: [Reminder] = []
    @Published var filteredReminders: [Reminder] = []
    @Published var allTags: [String] = []
    @Published var selectedTags: Set<String> = []
    @Published var showingAddReminder = false
    @Published var showingAudioRecorder = false
    @Published var selectedReminder: Reminder?
    
    private let modelContext: ModelContext
    private let notificationService = NotificationService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        setupNotificationObservers()
    }
    
    func loadReminders() {
        do {
            let descriptor = FetchDescriptor<Reminder>(
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )
            reminders = try modelContext.fetch(descriptor)
            applyFilters()
        } catch {
            handleError(error)
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        withAnimation(.easeInOut(duration: 0.3)) {
            Task {
                notificationService.cancelNotification(for: reminder)
            }
            modelContext.delete(reminder)
            reminders.removeAll { $0.id == reminder.id }
        }
    }
    
    func applyFilters() {
        if selectedTags.isEmpty || selectedTags == Set(allTags) {
            filteredReminders = reminders
        } else {
            filteredReminders = reminders.filter { reminder in
                reminder.tags.isEmpty ? false : !Set(reminder.tags).isDisjoint(with: selectedTags)
            }
        }
    }
    
    func toggleCompletion(_ reminder: Reminder) {
        withAnimation(.easeInOut(duration: 0.3)) {
            reminder.isCompleted.toggle()
        }
    }
    
    func snoozeReminder(_ reminder: Reminder) {
        let newDate = Calendar.current.date(byAdding: .minute, value: 15, to: reminder.date) ?? reminder.date
        reminder.date = newDate
        
        Task {
            notificationService.cancelNotification(for: reminder)
            notificationService.scheduleNotification(for: reminder)
        }
    }
    
    func completeReminder(_ reminder: Reminder) {
        reminder.isCompleted = true
        Task {
            notificationService.cancelNotification(for: reminder)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .snoozeReminder,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let reminderId = notification.object as? String,
                  let reminder = self?.reminders.first(where: { $0.id.uuidString == reminderId }) else { return }
            self?.snoozeReminder(reminder)
        }
        
        NotificationCenter.default.addObserver(
            forName: .completeReminder,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let reminderId = notification.object as? String,
                  let reminder = self?.reminders.first(where: { $0.id.uuidString == reminderId }) else { return }
            self?.completeReminder(reminder)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
