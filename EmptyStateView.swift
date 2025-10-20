//
//  EmptyStateView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 20.10.2025.
//


import SwiftUI
import SwiftData

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .fadeIn()
            
            Text("Добавьте первую задачу")
                .font(.title2)
                .foregroundColor(.white)
                .fadeIn()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
