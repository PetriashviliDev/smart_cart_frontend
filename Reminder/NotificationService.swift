//
//  NotificationService.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission granted: \(granted)")
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Напоминание"
        content.body = reminder.text
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
    
    func setupNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Отложить на 15 мин",
            options: []
        )
        
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Выполнено",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "REMINDER_CATEGORY",
            actions: [snoozeAction, completeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        guard let reminderId = response.notification.request.content.userInfo["reminderId"] as? String else { return }
        
        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            snoozeReminder(id: reminderId)
        case "COMPLETE_ACTION":
            completeReminder(id: reminderId)
        default:
            break
        }
    }
    
    private func snoozeReminder(id: String) {
        NotificationCenter.default.post(name: .snoozeReminder, object: id)
    }
    
    private func completeReminder(id: String) {
        NotificationCenter.default.post(name: .completeReminder, object: id)
    }
}

extension Notification.Name {
    static let snoozeReminder = Notification.Name("snoozeReminder")
    static let completeReminder = Notification.Name("completeReminder")
}
