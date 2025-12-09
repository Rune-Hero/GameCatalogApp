import Foundation
import Combine // Потрібен для @Published

// MARK: - LocalStorageService
class LocalStorageService: ObservableObject {
    
    // 1. Збереження списку ігор і підписка на зміни
    // Примітка: Припускаємо, що GameDetails є Codable, Identifiable.
    @Published var collection: [GameDetails] = []
    
    // Ключ для UserDefaults
    private let collectionKey = "myGameCollection"
    
    init() {
        loadCollection()
    }
    
    // MARK: - Local Data Operations
    
    private func loadCollection() {
        if let savedData = UserDefaults.standard.data(forKey: collectionKey),
           // Намагаємося декодувати збережені дані
           let decodedCollection = try? JSONDecoder().decode([GameDetails].self, from: savedData) {
            
            self.collection = decodedCollection
        } else {
            self.collection = []
        }
    }
    
    private func saveCollection() {
        if let encodedData = try? JSONEncoder().encode(collection) {
            UserDefaults.standard.set(encodedData, forKey: collectionKey)
            // Оскільки collection - це @Published, його зміна автоматично оновлює UI.
        }
    }
    
    // Додавання/Видалення гри
    func toggleCollectionStatus(for game: GameDetails) {
        if isGameInCollection(gameId: game.id) {
            // Видалення
            collection.removeAll { $0.id == game.id }
        } else {
            // Додавання
            collection.append(game)
        }
        
        saveCollection()
    }
    
    // Видалення гри (з MyCollectionView)
    func removeGame(gameId: Int) {
        collection.removeAll { $0.id == gameId }
        saveCollection()
    }
    
    // Перевірка чи гра вже збережена
    func isGameInCollection(gameId: Int) -> Bool {
        return collection.contains(where: { $0.id == gameId })
    }
}
