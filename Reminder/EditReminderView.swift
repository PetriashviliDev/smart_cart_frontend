//
//  EditReminderView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI
import SwiftData

struct EditReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditReminderViewModel
    
    init(reminder: Reminder) {
        let container = try! ModelContainer(for: Reminder.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: EditReminderViewModel(reminder: reminder, modelContext: container.mainContext))
    }
    
    init(reminder: Reminder, modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: EditReminderViewModel(reminder: reminder, modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Текст напоминания") {
                    TextField("Введите текст", text: $viewModel.text, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Дата и время") {
                    HStack {
                        Text("Дата")
                        Spacer()
                        Button(action: { viewModel.showingDatePicker.toggle() }) {
                            Text(viewModel.selectedDate, style: .date)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Text("Время")
                        Spacer()
                        DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
                Section {
                    Button("Удалить напоминание", role: .destructive) {
                        viewModel.deleteReminder()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.saveChanges()
                        dismiss()
                    }
                    .disabled(!viewModel.isSaveEnabled)
                }
            }
            .sheet(isPresented: $viewModel.showingDatePicker) {
                //DatePickerSheet(selectedDate: $viewModel.selectedDate)
            }
            .alert("Ошибка", isPresented: $viewModel.showingError) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    let reminder = Reminder(text: "Тестовое напоминание", date: Date(), priority: .high)
    return EditReminderView(reminder: reminder)
        .modelContainer(for: Reminder.self, inMemory: true)
}

