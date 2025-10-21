//
//  AddReminderView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddReminderViewModel
    
    init() {
        let container = try! ModelContainer(for: Reminder.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: AddReminderViewModel(modelContext: container.mainContext))
    }
    
    init(modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: AddReminderViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    TextField("Что хотите запланировать?", text: $viewModel.text, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section() {
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
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.saveReminder()
                        dismiss()
                    }
                    .disabled(!viewModel.isSaveEnabled)
                }
            }
            .sheet(isPresented: $viewModel.showingDatePicker) {
                DatePickerSheet(selectedDate: $viewModel.selectedDate)
            }
            .alert("Ошибка", isPresented: $viewModel.showingError) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            DatePicker("Выберите дату", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .navigationTitle("Дата")
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

#Preview {
    AddReminderView()
        .modelContainer(for: Reminder.self, inMemory: true)
}

