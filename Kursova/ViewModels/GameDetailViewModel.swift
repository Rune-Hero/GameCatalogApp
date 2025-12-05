import Foundation
import Combine // Додаємо для підписки

@MainActor
class GameDetailViewModel: ObservableObject {
    @Published var gameDetails: GameDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Нова властивість для стану кнопки
    @Published var isInCollection: Bool = false
    
    private let gameId: Int
    private var cancellables = Set<AnyCancellable>() // Для управління підписками
    
    init(gameId: Int) {
        self.gameId = gameId
    }
    
    // Новий метод для налаштування підписки та початкової перевірки
    func setupCollectionTracking(with localStorageService: LocalStorageService) {
        
        // 1. Налаштовуємо початковий статус
        self.isInCollection = localStorageService.isGameInCollection(gameId: self.gameId)
        
        // 2. Підписуємося на зміни в колекції сервісу
        localStorageService.$collection
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Оновлюємо стан isInCollection, коли колекція змінюється
                self.isInCollection = localStorageService.isGameInCollection(gameId: self.gameId)
            }
            .store(in: &cancellables)
    }
    
    func fetchGameDetails() async {
        isLoading = true
        errorMessage = nil
        do {
            let details = try await NetworkService.shared.fetchGameDetails(id: gameId)
            self.gameDetails = details
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // Нова функція для додавання/видалення з колекції, яка приймає сервіс
    func toggleCollectionStatus(in localStorageService: LocalStorageService) {
            guard let game = gameDetails else { return }
            
            // 1. Виконуємо додавання/видалення
            localStorageService.toggleCollectionStatus(for: game)
            
            // 2. Явно оновлюємо стан (це спрацює миттєво)
            // Ми використовуємо оновлений стан LocalStorageService
            self.isInCollection = localStorageService.isGameInCollection(gameId: game.id)
        }
}
