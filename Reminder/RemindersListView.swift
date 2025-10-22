//
//  RemindersListView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: RemindersListViewModel
    @State private var showingSettings = false
    @State private var showingAddFullScreen = false
    @Namespace private var bottomBarNamespace
    
    @State private var selection: Date
    @State private var title: String = Calendar.monthAndYear(from: .now)
    @State private var focusedWeek: Week
    @State private var calendarType: CalendarType = .week
    @State private var isDragging: Bool = false
    
    @State private var dragProgress: CGFloat = .zero
    @State private var initialDragOffset: CGFloat? = nil
    @State private var verticalDragOffset: CGFloat = .zero
    
    // Получать из календаря
    private let symbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private let tags = TagProvider.shared.tags
    
    enum CalendarType {
        case week
        case month
    }
    
    init() {
            let container = try! ModelContainer(for: Reminder.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            self.init(modelContext: container.mainContext)
        }
    
    init(modelContext: ModelContext) {
            let selectedDate = Date.now
            self._selection = State(initialValue: selectedDate)
            let nearestMonday = Calendar.nearestMonday(from: selectedDate)
            let currentWeek = Calendar.currentWeek(from: nearestMonday)
            self._focusedWeek = State(initialValue: Week(days: currentWeek, order: .current))
            self._viewModel = StateObject(wrappedValue: RemindersListViewModel(modelContext: modelContext))
            self._title = State(initialValue: Calendar.monthAndYear(from: selectedDate))
        }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.primary.opacity(0.9)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text(title)
                        .font(.title.bold())
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
                
                VStack(spacing: .zero) {
                    HStack {
                        ForEach(symbols, id: \.self) { symbol in
                            Text(symbol)
                                .fontWeight(.medium)
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(Color.white)
                            
                            if symbol != symbols.last {
                                Spacer()
                            }
                        }
                    }
                    
                    VStack {
                        switch calendarType {
                        case .week:
                            WeekCalendarView(
                                $title,
                                selection: $selection,
                                focused: $focusedWeek,
                                isDragging: isDragging
                            )
                        case .month:
                            MonthCalendarView(
                                $title,
                                selection: $selection,
                                focused: $focusedWeek,
                                isDragging: isDragging,
                                dragProgress: dragProgress
                            )
                        }
                    }
                    .frame(height: Constants.dayHeight + verticalDragOffset)
                    .clipped()
                }
                
                TagChipsView(tags: tags, selectedTags: tags) { tag, isSelected in
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
                
                // Капсула для растягивания календаря
                Capsule()
                    .fill(.white)
                    .frame(width: 70, height: 3)
                    .padding(.bottom, 6)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            switch calendarType {
                            case .week:
                                calendarType = .month
                                verticalDragOffset = Constants.monthHeight - Constants.dayHeight
                                dragProgress = 1.0
                            case .month:
                                calendarType = .week
                                verticalDragOffset = 0
                                dragProgress = 0
                            }
                        }
                    }
                    .padding(.top)
                
                if viewModel.filteredReminders.isEmpty {
                    EmptyStateView()
                } else { }
            }
            .onChange(of: selection) { _, newValue in
                title = Calendar.monthAndYear(from: newValue)
            }
            .onChange(of: focusedWeek) { _, n in
                print(n.id)
            }
            .gesture(
                DragGesture(minimumDistance: .zero)
                    .onChanged { value in
                        isDragging = true
                        calendarType = verticalDragOffset == 0 ? .week : .month
                        
                        if initialDragOffset == nil {
                            initialDragOffset = verticalDragOffset
                        }
                        
                        verticalDragOffset = max(
                            .zero,
                            min(
                                (initialDragOffset ?? 0) + value.translation.height,
                                Constants.monthHeight - Constants.dayHeight
                            )
                        )
                        
                        dragProgress = verticalDragOffset / (Constants.monthHeight - Constants.dayHeight)
                    }
                    .onEnded { value in
                        isDragging = false
                        initialDragOffset = nil
                        
                        withAnimation {
                            switch calendarType {
                            case .week:
                                if verticalDragOffset > Constants.monthHeight / 3 {
                                    verticalDragOffset = Constants.monthHeight - Constants.dayHeight
                                } else {
                                    verticalDragOffset = 0
                                }
                            case .month:
                                if verticalDragOffset < Constants.monthHeight / 3 {
                                    verticalDragOffset = 0
                                } else {
                                    verticalDragOffset = Constants.monthHeight - Constants.dayHeight
                                }
                            }
                            
                            dragProgress = verticalDragOffset / (Constants.monthHeight - Constants.dayHeight)
                        } completion: {
                            calendarType = verticalDragOffset == 0 ? .week : .month
                        }
                    }
            )
            .padding(.horizontal, 20)
        }
    }
}


#Preview {
    RemindersListView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
