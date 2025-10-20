//
//  MonthView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 18.10.2025.
//

import SwiftUI

struct MonthView: View {
    let month: Month
    let dragProgress: CGFloat
    
    @Binding var focused: Week
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(month.weeks) { week in
                WeekView(week: week, selectedDate: $selectedDate, dragProgress: dragProgress, hideDifferentMonth: true)
                    .opacity(focused == week ? 1 : dragProgress)
                    .frame(height: 100 / CGFloat(month.weeks.count)) // Constants.monthHeight
            }
        }
    }
}

#Preview {
    MonthView(
        month: .init(from: .now, order: .current),
        dragProgress: 1,
        focused: .constant(.current),
        selectedDate: .constant(.now)
    )
}
