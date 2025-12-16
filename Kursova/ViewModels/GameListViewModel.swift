import Foundation
import SwiftUI
import Combine

enum SortOption: String, CaseIterable {
    case none = "Default"
    case nameAsc = "Name ↑"
    case nameDesc = "Name ↓"
    case ratingAsc = "Rating ↑"
    case ratingDesc = "Rating ↓"
    case released = "Newest First"
}

@MainActor
class GameListViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var selectedGenres: Set<String> = []
    @Published var sortOption: SortOption = .none
    
    private var currentPage = 1
    private var canLoadMore = true
    
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
            let genresString = selectedGenres.isEmpty ? nil : selectedGenres.sorted().joined(separator: ",")
            
            let fetchedGames = try await NetworkService.shared.fetchGames(
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                genre: genresString,
                page: currentPage
            )
            
            if currentPage == 1 {
                games = fetchedGames
            } else {
                games.append(contentsOf: fetchedGames)
            }
            
            canLoadMore = !fetchedGames.isEmpty
            print("✅ Завантажено \(fetchedGames.count) ігор (всього: \(games.count))")
            
            // Застосовуємо сортування ПІСЛЯ завантаження (якщо не Default)
            if sortOption != .none {
                applySort()
            }
            
        } catch {
            errorMessage = "Failed to load games. Please try again."
            print("❌ Помилка: \(error)")
        }
        
        isLoading = false
    }
    
    func applySort() {
        switch sortOption {
        case .none:
            // Не сортуємо
            break
            
        case .nameAsc:
            games.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            
        case .nameDesc:
            games.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
            }
            
        case .ratingAsc:
            games.sort { $0.rating < $1.rating }
        
        case .ratingDesc:
            games.sort { $0.rating > $1.rating }
            
        case .released:
            games.sort {
                guard let d1 = $0.released, let d2 = $1.released else { return false }
                return d1 > d2
            }
        }
        
        print("🔄 Застосовано сортування: \(sortOption.rawValue)")
    }
    
    // ВИПРАВЛЕНО: Функція зміни сортування
    func changeSortOption(to option: SortOption) async {
        sortOption = option
        
        if option == .none {
            // Якщо Default - перезавантажуємо дані з API
            print("🔄 Скидання сортування - перезавантаження з API")
            currentPage = 1
            canLoadMore = true
            games = []
            await fetchGames()
        } else {
            // Інакше просто сортуємо існуючий список
            applySort()
        }
    }
    
    func searchGames(query: String) async {
        searchQuery = query
        currentPage = 1
        canLoadMore = true
        await fetchGames()
    }
    
    func toggleGenre(_ genre: String) async {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
        
        print("🎮 Selected genres: \(selectedGenres)")
        
        currentPage = 1
        canLoadMore = true
        games = []
        await fetchGames()
    }
    
    func clearGenres() async {
        selectedGenres.removeAll()
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
