import Foundation
import SwiftUI

@MainActor
class GameListViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var selectedGenre: String? = nil  // ← фільтр за жанром
    
    private var currentPage = 1
    private var canLoadMore = true
    
    // Список популярних жанрів
    let availableGenres = [
        "action", "indie", "adventure", "rpg", "strategy",
        "shooter", "casual", "simulation", "puzzle", "arcade",
        "platformer", "racing", "sports", "fighting"
    ]
    
    func fetchGames() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedGames = try await NetworkService.shared.fetchGames(
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                genre: selectedGenre,
                page: currentPage
            )
            
            if currentPage == 1 {
                games = fetchedGames
            } else {
                games.append(contentsOf: fetchedGames)
            }
            
            canLoadMore = !fetchedGames.isEmpty
            print("Завантажено \(fetchedGames.count) ігор (всього: \(games.count))")
            
        } catch {
            errorMessage = "Failed to load games. Please try again."
            print("Помилка: \(error)")
        }
        
        isLoading = false
    }
    
    func searchGames(query: String) async {
        searchQuery = query
        currentPage = 1
        canLoadMore = true
        await fetchGames()
    }
    
    func filterByGenre(genre: String?) async {
        selectedGenre = genre
        currentPage = 1
        canLoadMore = true
        games = []
        await fetchGames()
    }
    
    func loadMoreGames() async {
        guard canLoadMore && !isLoading else { return }
        currentPage += 1
        await fetchGames()
    }
    
    func refresh() async {
        currentPage = 1
        canLoadMore = true
        games = []
        await fetchGames()
    }
}
