//
//  ContentView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI
import SwiftData

enum Constants {
    static let dayHeight: CGFloat = 48
    static let monthHeight: CGFloat = 48 * 5
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var notificationService = NotificationService.shared
    @State private var presentingAdd = false
    @State private var presentingMiniRecorder = false
    @State private var micPressed = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RemindersListView(modelContext: modelContext)
            
            HStack(spacing: 18) {
                Button {
                    presentingAdd = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Button {
                } label: {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: micPressed ? "microphone.fill" : "microphone")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .scaleEffect(micPressed ? 1.08 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: micPressed)
                    }
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.4)
                        .onChanged { _ in micPressed = true }
                        .onEnded { _ in
                            micPressed = false
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                presentingMiniRecorder = true
                            }
                        }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
        }
        .onAppear {
            Task {
                await notificationService.requestPermission()
                notificationService.setupNotificationCategories()
            }
        }
        .fullScreenCover(isPresented: $presentingAdd) {
            AddReminderView(modelContext: modelContext)
        }
        .overlay(alignment: .bottomTrailing) {
            if presentingMiniRecorder {
                MiniRecorderPanel(onClose: { withAnimation { presentingMiniRecorder = false } }) {
                    AudioRecordingView(modelContext: modelContext, autoStart: true)
                        .frame(width: 320, height: 230)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                        .shadow(radius: 6)
                }
                .padding(.trailing, 12)
                .padding(.bottom, 86)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
