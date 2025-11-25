import Foundation
import SwiftUI

@MainActor
class GameListViewModel: ObservableObject {
    // Дані, які відстежує SwiftUI
        @Published var games: [Game] = []
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var searchQuery: String = ""
        @Published var selectedGenre: String?
        
        // Приватні змінні для пагінації
        private var currentPage = 1
        private var canLoadMore = true
        
        // Основна функція - завантаження ігор
        func fetchGames() async {
            // Якщо вже завантажуємо - не запускаємо знову
            guard !isLoading else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let fetchedGames = try await NetworkService.shared.fetchGames(
                    searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                    page: currentPage
                )
                
                // Якщо перша сторінка - замінюємо список
                // Якщо ні - додаємо до існуючого
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
        
        // Пошук ігор
        func searchGames(query: String) async {
            searchQuery = query
            currentPage = 1
            canLoadMore = true
            await fetchGames()
        }
        
        // Завантаження наступної сторінки (пагінація)
        func loadMoreGames() async {
            guard canLoadMore && !isLoading else { return }
            currentPage += 1
            await fetchGames()
        }
        
        // Оновлення списку (pull to refresh)
        func refresh() async {
            currentPage = 1
            canLoadMore = true
            games = []
            await fetchGames()
        }
    }
