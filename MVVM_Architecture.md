# MVVM Architecture Documentation

## Обзор архитектуры

Приложение было рефакторено с использованием архитектурного паттерна MVVM (Model-View-ViewModel), что обеспечивает лучшее разделение ответственности, тестируемость и поддерживаемость кода.

## Структура MVVM

### Model (Модель)
- **Reminder** - основная модель данных с SwiftData
- **Priority** - перечисление приоритетов
- **Сервисы** - NetworkService, NotificationService, AudioRecordingService, ThemeManager

### View (Представление)
- **RemindersListView** - главный экран со списком напоминаний
- **AddReminderView** - добавление нового напоминания
- **EditReminderView** - редактирование существующего напоминания
- **AudioRecordingView** - запись аудио
- **SettingsView** - настройки приложения

### ViewModel (Модель представления)
- **BaseViewModel** - базовый класс с общей функциональностью
- **RemindersListViewModel** - логика главного экрана
- **AddReminderViewModel** - логика добавления напоминания
- **EditReminderViewModel** - логика редактирования напоминания
- **AudioRecordingViewModel** - логика записи аудио
- **SettingsViewModel** - логика настроек

## Преимущества MVVM

### 1. Разделение ответственности
- **View** отвечает только за отображение UI
- **ViewModel** содержит бизнес-логику и состояние
- **Model** представляет данные и бизнес-правила

### 2. Тестируемость
- ViewModels можно тестировать независимо от UI
- Легко создавать unit-тесты для бизнес-логики
- Mock-объекты для зависимостей

### 3. Переиспользование
- ViewModels можно использовать в разных View
- Общая логика вынесена в BaseViewModel
- Сервисы инкапсулируют специфичную функциональность

### 4. Поддерживаемость
- Четкая структура кода
- Легко добавлять новую функциональность
- Простое понимание архитектуры

## Ключевые компоненты

### BaseViewModel
```swift
@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    func handleError(_ error: Error) { ... }
    func clearError() { ... }
}
```

### Пример ViewModel
```swift
@MainActor
class AddReminderViewModel: BaseViewModel {
    @Published var text = ""
    @Published var selectedDate = Date()
    @Published var selectedPriority: Priority = .medium
    
    var isSaveEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func saveReminder() { ... }
}
```

### Пример View
```swift
struct AddReminderView: View {
    @StateObject private var viewModel: AddReminderViewModel
    
    var body: some View {
        Form {
            TextField("Введите текст", text: $viewModel.text)
            // ...
        }
    }
}
```

## Паттерны и принципы

### 1. Single Responsibility Principle
Каждый класс имеет одну ответственность:
- View - отображение
- ViewModel - бизнес-логика
- Model - данные

### 2. Dependency Injection
ViewModels получают зависимости через конструктор:
```swift
init(modelContext: ModelContext) {
    self.modelContext = modelContext
}
```

### 3. Reactive Programming
Использование @Published для реактивных обновлений UI:
```swift
@Published var reminders: [Reminder] = []
```

### 4. Error Handling
Централизованная обработка ошибок в BaseViewModel:
```swift
func handleError(_ error: Error) {
    errorMessage = error.localizedDescription
    showingError = true
}
```

## Тестирование

### Unit Tests для ViewModels
```swift
func testAddReminderViewModel() {
    let viewModel = AddReminderViewModel(modelContext: modelContext)
    
    XCTAssertFalse(viewModel.isSaveEnabled)
    
    viewModel.text = "Test reminder"
    XCTAssertTrue(viewModel.isSaveEnabled)
}
```

### Mock-объекты
```swift
class MockNetworkService: NetworkServiceProtocol {
    func processAudioRecording(audioData: Data) async throws -> [ReminderResponse] {
        return [ReminderResponse(text: "Test", date: "2025-01-01", priority: "medium")]
    }
}
```

## Миграция с MVC

### До (MVC)
- Логика смешана с UI
- Сложно тестировать
- Нарушение принципа единственной ответственности

### После (MVVM)
- Четкое разделение ответственности
- Легко тестировать ViewModels
- Переиспользуемая бизнес-логика
- Реактивные обновления UI

## Рекомендации

1. **Всегда используйте @MainActor** для ViewModels
2. **Инжектируйте зависимости** через конструктор
3. **Обрабатывайте ошибки** централизованно
4. **Пишите тесты** для ViewModels
5. **Используйте @Published** для реактивных свойств
6. **Избегайте прямого доступа** к ModelContext в View
