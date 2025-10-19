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
    
    @State private var selection: Date?
    @State private var title: String = Calendar.monthAndYear(from: .now)
    @State private var focusedWeek: Week = .current
    @State private var calendarType: CalendarType = .week
    @State private var isDragging: Bool = false
    
    @State private var dragProgress: CGFloat = .zero
    @State private var initialDragOffset: CGFloat? = nil
    @State private var verticalDragOffset: CGFloat = .zero
    
    private let symbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    enum CalendarType {
        case week
        case month
    }
    
    init() {
        let container = try! ModelContainer(for: Reminder.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        self._viewModel = StateObject(wrappedValue: RemindersListViewModel(modelContext: container.mainContext))
    }
    
    init(modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: RemindersListViewModel(modelContext: modelContext))
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
                .padding(.horizontal, 25)
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
                    .padding(.horizontal)
                    
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
                
                Capsule()
                    .fill(.white)
                    .frame(width: 70, height: 3)
                    .padding(.bottom, 6)
            }
            .onChange(of: selection) { _, newValue in
                guard let newValue else { return }
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
            
        }
    }
    
//    var body: some View {
//        NavigationView {
//            ZStack(alignment: .top) {
//                VStack(spacing: 0) {
//                    
//                    
//                    TagFilterBar(
//                        allTags: viewModel.allTags,
//                        selected: viewModel.selectedTags,
//                        onToggle: { tag in viewModel.toggleTag(tag) },
//                        onSelectAll: { viewModel.selectAllTags() },
//                        onClearAll: { viewModel.clearAllTags() }
//                    )
//                    .padding(.horizontal)
//                    .padding(.bottom, 6)
//                    
//                    if viewModel.filteredReminders.isEmpty {
//                        EmptyStateView()
//                    } else {
//                        List {
//                            ForEach(viewModel.filteredReminders) { reminder in
//                                ReminderRowView(reminder: reminder)
//                                    .onTapGesture {
//                                        viewModel.selectedReminder = reminder
//                                    }
//                                    .swipeActions(edge: .trailing) {
//                                        Button("Удалить", role: .destructive) {
//                                            viewModel.deleteReminder(reminder)
//                                        }
//                                        
//                                        Button("Выполнено") {
//                                            viewModel.toggleCompletion(reminder)
//                                        }
//                                        .tint(.green)
//                                    }
//                                    .slideInFromBottom()
//                            }
//                        }
//                        .listStyle(PlainListStyle())
//                    }
//                    
//                    Spacer(minLength: 0)
//                        .frame(height: 60)
//                }
//                
//                if viewModel.showingAudioRecorder {
//                    MiniRecorderPanel {
//                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
//                            viewModel.showingAudioRecorder = false
//                        }
//                    } content: {
//                        AudioRecordingView(modelContext: modelContext)
//                            .frame(width: 320, height: 230)
//                            .clipShape(RoundedRectangle(cornerRadius: 14))
//                    }
//                    .transition(.move(edge: .trailing).combined(with: .opacity))
//                    .padding(.trailing, 12)
//                    .padding(.bottom, 76)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//                }
//            }
//            .sheet(isPresented: $showingSettings) {
//                SettingsView()
//            }
//            .fullScreenCover(isPresented: $showingAddFullScreen) {
//                AddReminderView(modelContext: modelContext)
//            }
//            .sheet(item: $viewModel.selectedReminder) { reminder in
//                EditReminderView(reminder: reminder, modelContext: modelContext)
//            }
//            .alert("Ошибка", isPresented: $viewModel.showingError) {
//                Button("OK") { viewModel.clearError() }
//            } message: {
//                Text(viewModel.errorMessage ?? "")
//            }
//        }
//        .onAppear {
//            viewModel.loadReminders()
//        }
//    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .fadeIn()
            
            Text("Нет напоминаний")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .fadeIn()
            
            Text("Добавьте первое напоминание")
                .font(.body)
                .foregroundColor(.secondary)
                .fadeIn()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Tag Chips

struct TagChips: View {
    let tags: [String]
    
    var body: some View {
        FlexibleTagContainer(tags: tags) { tag in
            Text(tag)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tagColor(tag).opacity(0.15))
                .foregroundColor(tagColor(tag))
                .clipShape(Capsule())
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
        default:
            return .teal
        }
    }
}

struct FlexibleTagContainer<Content: View>: View {
    let tags: [String]
    let content: (String) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            var currentRowWidth: CGFloat = 0
            var rows: [[String]] = [[]]
            let maxWidth = UIScreen.main.bounds.width - 48
            
            // naive line breaking in body builder scope
            ForEach(rows.indices, id: \.self) { _ in EmptyView() }
            
            GeometryReader { proxy in
                flowLayout(width: min(maxWidth, proxy.size.width))
            }
            .frame(height: intrinsicHeight(width: maxWidth))
        }
    }
    
    private func chipSize(for text: String) -> CGSize {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.sizeToFit()
        return CGSize(width: label.bounds.width + 16, height: label.bounds.height + 8)
    }
    
    private func flowLayout(width: CGFloat) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0
        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags.enumerated()), id: \.offset) { _, tag in
                let size = chipSize(for: tag)
                content(tag)
                    .alignmentGuide(.leading) { _ in
                        let result = x
                        if x + size.width > width {
                            x = 0
                            y -= size.height + 6
                        }
                        let out = x
                        x += size.width + 6
                        return out
                    }
                    .alignmentGuide(.top) { _ in y }
            }
        }
    }
    
    private func intrinsicHeight(width: CGFloat) -> CGFloat {
        var x: CGFloat = 0
        var rows: CGFloat = 1
        for tag in tags {
            let w = chipSize(for: tag).width + 6
            if x + w > width {
                rows += 1
                x = 0
            }
            x += w
        }
        return rows * (chipSize(for: "A").height + 6)
    }
}

struct ReminderRowView: View {
    let reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.text)
                    .font(.body)
                    .strikethrough(reminder.isCompleted)
                    .foregroundColor(reminder.isCompleted ? .secondary : .primary)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(reminder.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(reminder.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !reminder.tags.isEmpty {
                    TagChips(tags: reminder.tags)
                }
            }
            
            Spacer()
            if reminder.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Calendar Header

struct MonthCalendarHeader: View {
    @Binding var currentMonth: Date
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { currentMonth = Calendar.current.addMonths(-1, to: currentMonth) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            
            Spacer()
            
            Text(currentMonth.formatted(.dateTime.year().month(.wide)))
                .font(.title3).bold()
                .contentTransition(.numericText())
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { currentMonth = Calendar.current.addMonths(1, to: currentMonth) }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
        }
    }
}

// MARK: - Calendar Grid

struct MonthCalendarGrid: View {
    @Binding var currentMonth: Date
    let reminders: [Reminder]
    @State private var selectedDay: Date? = nil
    @State private var showDaySheet = false
    
    private var days: [Date] {
        Calendar.current.daysForMonthGrid(anchoredAt: currentMonth)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(Calendar.current.shortWeekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { day in
                    let isCurrentMonth = Calendar.current.isDate(day, equalTo: currentMonth, toGranularity: .month)
                    let dayReminders = reminders.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    let hasReminder = !dayReminders.isEmpty
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.caption)
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(hasReminder ? Color.blue.opacity(0.15) : Color.clear)
                        )
                        .foregroundColor(isCurrentMonth ? .primary : .secondary)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDay = day
                            showDaySheet = true
                        }
                        .overlay(alignment: .bottom) {
                            if !dayReminders.isEmpty {
                                DayTagIndicators(reminders: dayReminders)
                                    .padding(.bottom, 2)
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showDaySheet) {
            let day = selectedDay ?? Date()
            DayRemindersSheet(date: day, reminders: reminders.filter { Calendar.current.isDate($0.date, inSameDayAs: day) })
        }
    }
}

// MARK: - Tag Filter Bar

struct TagFilterBar: View {
    let allTags: [String]
    let selected: Set<String>
    let onToggle: (String) -> Void
    let onSelectAll: () -> Void
    let onClearAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("Все") { onSelectAll() }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                
                Button("Сброс") { onClearAll() }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.12))
                    .foregroundColor(.red)
                    .clipShape(Capsule())
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allTags, id: \.self) { tag in
                        let isOn = selected.contains(tag)
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isOn ? Color.accentColor.opacity(0.2) : Color(.systemGray5))
                            .foregroundColor(isOn ? .accentColor : .secondary)
                            .clipShape(Capsule())
                            .onTapGesture { onToggle(tag) }
                    }
                }
            }
        }
    }
}

// MARK: - Day Tag Indicators (calendar tiny chips)

struct DayTagIndicators: View {
    let reminders: [Reminder]
    
    private var tags: [String] {
        Array(Set(reminders.flatMap { $0.tags })).sorted().prefix(3).map { String($0) }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(tags, id: \.self) { tag in
                Circle()
                    .fill(tagColor(tag))
                    .frame(width: 5, height: 5)
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
}

// MARK: - Day Reminders Sheet

struct DayRemindersSheet: View {
    let date: Date
    let reminders: [Reminder]
    
    var body: some View {
        NavigationView {
            List(reminders) { reminder in
                VStack(alignment: .leading, spacing: 6) {
                    Text(reminder.text)
                        .font(.body)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(reminder.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !reminder.tags.isEmpty {
                        TagChips(tags: reminder.tags)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle(date.formatted(.dateTime.day().month(.wide).year()))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Bottom Toolbar

struct BottomToolbar: View {
    let onBell: () -> Void
    let onSettings: () -> Void
    let onPlus: () -> Void
    let onMic: () -> Void
    
    var body: some View {
        HStack(spacing: 18) {
            Button(action: onBell) {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: onPlus) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.blue)
                    .shadow(radius: 2)
            }
            .transition(.scale.combined(with: .opacity))
            
            Spacer()
            
            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            // Floating mic
            Button(action: onMic) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal, 12)
    }
}

// MARK: - Mini Recorder Panel

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

// MARK: - Helpers

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
    
    func addMonths(_ value: Int, to date: Date) -> Date {
        self.date(byAdding: .month, value: value, to: date) ?? date
    }
    
    func daysForMonthGrid(anchoredAt date: Date) -> [Date] {
        let start = startOfMonth(for: date)
        let range = range(of: .day, in: .month, for: start) ?? 1..<29
        let firstWeekday = component(.weekday, from: start)
        let leading = (firstWeekday + 6) % 7 // make Monday=1
        let days = range.compactMap { self.date(byAdding: .day, value: $0 - 1, to: start) }
        let leadingDates = (0..<leading).compactMap { self.date(byAdding: .day, value: -($0 + 1), to: start) }.reversed()
        let total = leadingDates + days
        // pad to complete weeks (multiple of 7)
        let remainder = total.count % 7
        if remainder == 0 { return total }
        let trailingNeeded = 7 - remainder
        let last = total.last ?? start
        let trailing = (1...trailingNeeded).compactMap { self.date(byAdding: .day, value: $0, to: last) }
        return total + trailing
    }
    
    func shortWeekdaySymbols() -> [String] {
        var symbols = shortWeekdaySymbols
        // make Monday first
        let sunday = symbols.removeFirst()
        symbols.append(sunday)
        return symbols
    }
}

#Preview {
    RemindersListView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
