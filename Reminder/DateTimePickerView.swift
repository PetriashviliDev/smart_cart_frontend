//
//  DateTimePickerView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 21.10.2025.
//

import SwiftUI

struct DateTimePickerView: View {
    @State private var selectedDate: Date
    
    init() {
        let calendar = Calendar.current
        let defaultDate = calendar.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        _selectedDate = State(initialValue: defaultDate)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Выбранная дата и время")
                    .font(.headline)
                
                Text(formatDateTime(selectedDate))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            DateTimeWheelPicker(selectedDate: $selectedDate)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy 'в' HH:mm"
        return formatter.string(from: date)
    }
}

struct DateTimeWheelPicker: View {
    @Binding var selectedDate: Date
    
    @State private var selectedDayIndex: Int
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    
    private let calendar = Calendar.current
    private let daysToShow = 90
    
    private let quickSelectOptions: [QuickSelectOption] = [
        .init(title: "30 минут", duration: 30, unit: .minute),
        .init(title: "1 час", duration: 1, unit: .hour),
        .init(title: "3 часа", duration: 3, unit: .hour),
        .init(title: "12 часов", duration: 12, unit: .hour),
        .init(title: "1 день", duration: 1, unit: .day),
        .init(title: "2 дня", duration: 2, unit: .day)
    ]
    
    private var availableDates: [Date] {
        var dates: [Date] = []
        let startDate = Date()
        
        for day in 0..<daysToShow {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private var availableHours: [Int] {
        Array(0...23)
    }
    
    private var availableMinutes: [Int] {
        Array(stride(from: 0, through: 55, by: 5))
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: .zero) {
                HStack(spacing: .zero) {
                    Picker("День", selection: $selectedDayIndex) {
                        ForEach(0..<availableDates.count, id: \.self) { index in
                            Text(dayString(for: availableDates[index]))
                                .font(.body)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 140)
                    .onChange(of: selectedDayIndex) {
                        updateSelectedDate()
                    }
                    
                    Picker("Час", selection: $selectedHour) {
                        ForEach(availableHours, id: \.self) { hour in
                            Text(String(format: "%2d", hour))
                                .font(.body)
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                    .onChange(of: selectedHour) {
                        updateSelectedDate()
                    }
                    
                    Picker("Минута", selection: $selectedMinute) {
                        ForEach(availableMinutes, id: \.self) { minute in
                            Text(String(format: "%2d", minute))
                                .font(.body)
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                    .onChange(of: selectedMinute) {
                        updateSelectedDate()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            quickSelectView
        }
    }
    
    private var quickSelectView: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Напомнить через")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(quickSelectOptions) { option in
                    Button(action: {
                        selectQuickOption(option)
                    }) {
                        Text(option.title)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.green.gradient)
                            )
                    }
                }
            }
        }
        .padding(.top, 30)
    }
    
    private func dayString(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInTomorrow(date) {
            return "Завтра"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, EEE"
            return formatter.string(from: date)
        }
    }
    
    private func updateSelectedDate() {
        let selectedDay = availableDates[selectedDayIndex]
        
        if let newDate = calendar.date(
            bySettingHour: selectedHour,
            minute: selectedMinute,
            second: 0,
            of: selectedDay
        ) {
            selectedDate = newDate
        }
    }
    
    private func selectCurrentTimePlus5() {
        let nowPlus5 = calendar.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        setDateTime(to: nowPlus5)
    }
    
    private func selectQuickOption(_ option: QuickSelectOption) {
        let newDate = calendar.date(byAdding: option.unit, value: option.duration, to: Date()) ?? Date()
        setDateTime(to: newDate)
    }
    
    private func setDateTime(to date: Date) {
        if let index = availableDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDayIndex = index
        }
        
        selectedHour = calendar.component(.hour, from: date)
        
        let minute = calendar.component(.minute, from: date)
        selectedMinute = availableMinutes.min(by: {
            abs($0 - minute) < abs($1 - minute)
        }) ?? 0
        
        updateSelectedDate()
    }
}

struct QuickSelectOption: Identifiable {
    let id = UUID()
    let title: String
    let duration: Int
    let unit: Calendar.Component
}

extension DateTimeWheelPicker {
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        
        let calendar = Calendar.current
        let date = selectedDate.wrappedValue
        let availableDates = Self.getAvailableDates()
        
        let dayIndex = availableDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) ?? 0
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let roundedMinute = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55].min(by: {
            abs($0 - minute) < abs($1 - minute)
        }) ?? 0
        
        self._selectedDayIndex = State(initialValue: dayIndex)
        self._selectedHour = State(initialValue: hour)
        self._selectedMinute = State(initialValue: roundedMinute)
    }
    
    private static func getAvailableDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        let startDate = Date()
        let daysToShow = 90
        
        for day in 0..<daysToShow {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
}

#Preview {
    DateTimePickerView()
}
