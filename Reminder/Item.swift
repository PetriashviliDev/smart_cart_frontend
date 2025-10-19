//
//  Item.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftData

@Model
class Reminder {
    var id: UUID
    var text: String
    var date: Date
    var priority: Priority
    var isCompleted: Bool
    var createdAt: Date
    var audioURL: String?
    var tags: [String]
    
    init(text: String, date: Date, priority: Priority = .medium, audioURL: String? = nil, tags: [String] = []) {
        self.id = UUID()
        self.text = text
        self.date = date
        self.priority = priority
        self.isCompleted = false
        self.createdAt = Date()
        self.audioURL = audioURL
        self.tags = tags
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Низкий"
        case .medium: return "Средний"
        case .high: return "Высокий"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}
