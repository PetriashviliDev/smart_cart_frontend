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
            
            HStack(spacing: 15) {
                Spacer()
                Button {
                    presentingAdd = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }
                                
                Button {
                } label: {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: micPressed ? "waveform.badge.microphone" : "microphone")
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
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
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

struct MiniRecorderPanel<Content: View>: View {
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            content()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .background(Color(.systemBackground).clipShape(Circle()))
            }
            .padding(6)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
