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
    
    private let tags = TagProvider.shared.tags
    
    init() {
        let container = try! ModelContainer(for: Reminder.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: AddReminderViewModel(modelContext: container.mainContext))
    }
    
    init(modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: AddReminderViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color.primary.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.secondary)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "chevron.left")
                                    .imageScale(.large)
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        ZStack(alignment: .topLeading) {
                            
                            if viewModel.text.isEmpty {
                                Text("Что хотите запланировать?")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                            }
                            
                            TextField("", text: $viewModel.text, axis: .vertical)
                                .lineLimit(3...6)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.primary.opacity(0))
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        
                        VStack(alignment: .leading) {
                            TagChipsView(tags: tags, selectedTags: [], showControlTag: false) { tag, isSelected in
                                HStack(spacing: 8) {
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                    
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    ZStack {
                                        Capsule()
                                            .fill(.secondary)
                                        
                                        Capsule()
                                            .fill(.green.gradient)
                                            .opacity(isSelected ? 1 : 0)
                                    }
                                )
                            } didChangeSelection: { _ in }
                        }
                        .padding(.top, 10)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "bell")
                                    .foregroundColor(.secondary)
                                Text("Напомнить")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.primary.opacity(0))
                                    .stroke(Color.secondary, lineWidth: 1)
                            )
                            .onTapGesture {
                                viewModel.showingDatePicker.toggle()
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                Text("Повторить")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.primary.opacity(0))
                                    .stroke(Color.secondary, lineWidth: 1)
                            )
                            .onTapGesture {
                                viewModel.showingDatePicker.toggle()
                            }
                        }
                        .padding(.top, 10)
                                                
                        Spacer()
                        
                        Button("Сохранить") {
                            viewModel.saveReminder()
                            dismiss()
                        }
                        .disabled(!viewModel.isSaveEnabled)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isSaveEnabled ? Color.green : Color.secondary)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .sheet(isPresented: $viewModel.showingDatePicker) {
                        DateTimePickerView(selectedDate: $viewModel.selectedDate)
                    }
                    .alert("Ошибка", isPresented: $viewModel.showingError) {
                        Button("OK") { viewModel.clearError() }
                    } message: {
                        Text(viewModel.errorMessage ?? "")
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    AddReminderView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
