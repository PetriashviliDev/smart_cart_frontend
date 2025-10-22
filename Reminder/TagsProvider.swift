import Foundation

class TagProvider {
    
    // MARK: - Singleton
    static let shared = TagProvider()
    
    // MARK: - Private Properties
    private let tagList = ["Образование", "Медицина", "Работа", "Личное", "Покупки", "Праздник", "Прочее"]
    
    // MARK: - Public Properties
    var tags: [String] {
        return tagList
    }
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Public Methods
    func getAllTags() -> [String] {
        return tagList
    }
    
    func getTag(at index: Int) -> String? {
        guard index >= 0 && index < tagList.count else { return nil }
        return tagList[index]
    }
    
    func containsTag(_ tag: String) -> Bool {
        return tagList.contains(tag)
    }
}
