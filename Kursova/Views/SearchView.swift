import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GameListViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let spacing: CGFloat = 12
                let padding: CGFloat = 16
                let cardWidth = (screenWidth - (padding * 2) - spacing) / 2
                let imageWidth = cardWidth - 24
                
                let columns = [
                    GridItem(.adaptive(minimum: cardWidth), spacing: spacing)
                ]
                
                ZStack {
                    VStack(spacing: 0) {
                        // Пошукове поле
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("Search games...", text: $searchText)
                                    .focused($isSearchFocused)
                                    .textFieldStyle(.plain)
                                    .autocorrectionDisabled()
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                        viewModel.games = []
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Результати пошуку
                        if viewModel.games.isEmpty && !viewModel.isLoading {
                            // Початковий стан або нічого не знайдено
                            VStack(spacing: 20) {
                                Spacer()
                                
                                if searchText.isEmpty {
                                    // Підказки до пошуку
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    
                                    Text("Search for games")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("Start typing to see results")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                    
                                    // Популярні запити
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Popular searches:")
                                            .font(.headline)
                                            .padding(.top, 20)
                                        
                                        ForEach(["GTA", "Minecraft", "The Witcher", "Call of Duty"], id: \.self) { query in
                                            Button(action: {
                                                searchText = query
                                            }) {
                                                HStack {
                                                    Image(systemName: "magnifyingglass")
                                                        .foregroundColor(.gray)
                                                    Text(query)
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                }
                                                .padding(.vertical, 8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 40)
                                    
                                } else {
                                    // Нічого не знайдено
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    
                                    Text("No results found")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("Try searching for something else")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        } else {
                            // Список результатів
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(viewModel.games) { game in
                                        NavigationLink(destination: GameDetailView(gameId: game.id)) {
                                            GameCardView(game: game, imageWidth: imageWidth)
                                        }
                                        .buttonStyle(CardButtonStyle())
                                        .onAppear {
                                            if game.id == viewModel.games.last?.id {
                                                Task { await viewModel.loadMoreGames() }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, padding)
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    
                    // Індикатор завантаження
                    if viewModel.isLoading {
                        LoadingView()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isSearchFocused = true
            }
            .onChange(of: searchText) { oldValue, newValue in
                // Затримка 0.5 секунди перед пошуком
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if searchText == newValue {  // Якщо текст не змінився за 0.5 сек
                        performSearch(query: newValue)
                    }
                }
            }
        }
    }
    
    private func performSearch(query: String) {
        // Якщо текст порожній - очищаємо результати
        guard !query.isEmpty else {
            viewModel.games = []
            return
        }
        
        // Мінімум 2 символи для пошуку (щоб не спамити API)
        guard query.count >= 2 else { return }
        
        Task {
            await viewModel.searchGames(query: query)
        }
    }
}

