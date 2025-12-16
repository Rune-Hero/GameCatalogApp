import Foundation
import Combine

// MARK: - LocalStorageService
class LocalStorageService: ObservableObject {
    
    @Published var collection: [GameDetails] = []
    
    private let collectionKey = "myGameCollection"
    
    init() {
        loadCollection()
    }
    
    // MARK: - Local Data Operations
    private func loadCollection() {
        if let savedData = UserDefaults.standard.data(forKey: collectionKey),
           let decodedCollection = try? JSONDecoder().decode([GameDetails].self, from: savedData) {
            
            self.collection = decodedCollection
        } else {
            self.collection = []
        }
    }
    
    private func saveCollection() {
        if let encodedData = try? JSONEncoder().encode(collection) {
            UserDefaults.standard.set(encodedData, forKey: collectionKey)
        }
    }
    
    func toggleCollectionStatus(for game: GameDetails) {
        if isGameInCollection(gameId: game.id) {
            collection.removeAll { $0.id == game.id }
        } else {
            collection.append(game)
        }
        
        saveCollection()
    }
    
    func removeGame(gameId: Int) {
        collection.removeAll { $0.id == gameId }
        saveCollection()
    }
    
    func isGameInCollection(gameId: Int) -> Bool {
        return collection.contains(where: { $0.id == gameId })
    }
}
