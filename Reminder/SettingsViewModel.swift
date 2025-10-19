//
//  SettingsViewModel.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class SettingsViewModel: BaseViewModel {
    @Published var currentTheme: AppTheme = .system
    @Published var showingAbout = false
    
    private let themeManager = ThemeManager()
    
    override init() {
        super.init()
        setupThemeObserver()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        themeManager.setTheme(theme)
    }
    
    func openNotificationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
    
    func showAbout() {
        showingAbout = true
    }
    
    private func setupThemeObserver() {
        themeManager.$currentTheme
            .assign(to: &$currentTheme)
    }
}
