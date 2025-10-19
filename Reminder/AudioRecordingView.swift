//
//  AudioRecordingView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI
import SwiftData

struct AudioRecordingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AudioRecordingViewModel
    private let autoStart: Bool
    
    init() {
        let container = try! ModelContainer(for: Reminder.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: AudioRecordingViewModel(modelContext: container.mainContext))
        self.autoStart = false
    }
    
    init(modelContext: ModelContext, autoStart: Bool = false) {
        self._viewModel = StateObject(wrappedValue: AudioRecordingViewModel(modelContext: modelContext))
        self.autoStart = autoStart
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: viewModel.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 80))
                        .foregroundColor(viewModel.isRecording ? .red : .blue)
                        .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isRecording)
                    
                    if viewModel.isRecording {
                        Text(viewModel.formattedDuration)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    } else {
                        Text("Нажмите для записи")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    if viewModel.isRecording {
                        Button("Остановить запись") {
                            viewModel.stopRecording()
                        }
                        .buttonStyle(RecordingButtonStyle(isRecording: true))
                    } else {
                        Button("Начать запись") {
                            viewModel.startRecording()
                        }
                        .buttonStyle(RecordingButtonStyle(isRecording: false))
                    }
                    
                    if viewModel.canProcessRecording {
                        Button("Обработать запись") {
                            viewModel.processRecording()
                            dismiss()
                        }
                        .buttonStyle(ProcessingButtonStyle(isProcessing: viewModel.isProcessing))
                        .disabled(viewModel.isProcessing)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Запись аудио")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert("Ошибка", isPresented: $viewModel.showingError) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                if autoStart && !viewModel.isRecording {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        viewModel.startRecording()
                    }
                }
            }
        }
    }
}

struct RecordingButtonStyle: ButtonStyle {
    let isRecording: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(isRecording ? Color.red : Color.blue)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ProcessingButtonStyle: ButtonStyle {
    let isProcessing: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            configuration.label
        }
        .font(.title2)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .frame(width: 200, height: 50)
        .background(Color.green)
        .clipShape(Capsule())
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AudioRecordingView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
