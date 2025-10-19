//
//  DayView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 18.10.2025.
//

import SwiftUI

struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(spacing: 12) {
            Text(Calendar.dayNumber(from: date))
                .background {
                    if date == selectedDate {
                        Circle()
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                    }
                }
        }
        .foregroundStyle(selectedDate == date ? Color.black : Color.white)
        .font(.system(.body, design: .rounded, weight: .medium))
        .onTapGesture {
            withAnimation(.easeInOut) {
                selectedDate = date
            }
        }
    }
}

#Preview {
    DayView(date: .now, selectedDate: .constant(nil))
}
