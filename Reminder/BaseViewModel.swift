//
//  BaseViewModel.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showingError = true
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}
