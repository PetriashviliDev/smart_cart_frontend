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
                
                Section("Теги") {
                    TagSelector(available: viewModel.availableTags, selected: $viewModel.selectedTags)
                }

                // Приоритет убран по требованию
            }
            .navigationTitle("Новое напоминание")
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

// MARK: - Tag Selector

struct TagSelector: View {
    let available: [String]
    @Binding var selected: Set<String>
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8, alignment: .leading)], spacing: 8) {
            ForEach(available, id: \.self) { tag in
                let isOn = selected.contains(tag)
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(tagBackground(tag, isOn: isOn))
                    .foregroundColor(tagForeground(tag, isOn: isOn))
                    .clipShape(Capsule())
                    .onTapGesture {
                        if isOn { selected.remove(tag) } else { selected.insert(tag) }
                    }
                    .animation(.easeInOut(duration: 0.15), value: selected)
            }
        }
    }
    
    private func tagColor(_ tag: String) -> Color {
        switch tag.lowercased() {
        case "образование": return .blue
        case "медицина": return .red
        case "работа": return .orange
        case "личное": return .purple
        case "покупки": return .green
        case "прочее": return .gray
        default: return .teal
        }
    }
    
    private func tagBackground(_ tag: String, isOn: Bool) -> Color {
        let c = tagColor(tag)
        return isOn ? c.opacity(0.25) : Color(.systemGray5)
    }
    
    private func tagForeground(_ tag: String, isOn: Bool) -> Color {
        let c = tagColor(tag)
        return isOn ? c : .secondary
    }
}

#Preview {
    AddReminderView()
        .modelContainer(for: Reminder.self, inMemory: true)
}

