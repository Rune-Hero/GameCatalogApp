import Foundation

@MainActor
class GameDetailViewModel: ObservableObject {
    @Published var gameDetails: GameDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let gameId: Int
    
    init(gameId: Int) {
        self.gameId = gameId
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
}
