//
//  SettingsView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("Внешний вид") {
                    Picker("Тема", selection: $viewModel.currentTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                    .onChange(of: viewModel.currentTheme) { _, newTheme in
                        viewModel.setTheme(newTheme)
                    }
                }
                
                Section("Уведомления") {
                    Button("Настройки уведомлений") {
                        viewModel.openNotificationSettings()
                    }
                }
                
                Section("О приложении") {
                    Button("О программе") {
                        viewModel.showAbout()
                    }
                    
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
            .sheet(isPresented: $viewModel.showingAbout) {
                AboutView()
            }
        }
        .preferredColorScheme(viewModel.currentTheme.colorScheme)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Reminder")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Приложение для управления напоминаниями")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Возможности:")
                        .font(.headline)
                    
                    FeatureRow(icon: "text.cursor", text: "Добавление напоминаний текстом")
                    FeatureRow(icon: "mic.fill", text: "Запись аудио с распознаванием")
                    FeatureRow(icon: "bell.fill", text: "Уведомления по расписанию")
                    FeatureRow(icon: "paintbrush.fill", text: "Настройка тем")
                    FeatureRow(icon: "widget", text: "Виджет для быстрого доступа")
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("О программе")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    SettingsView()
}
