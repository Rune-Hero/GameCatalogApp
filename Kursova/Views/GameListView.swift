import SwiftUI
import Foundation

struct GameListView: View {
    @StateObject private var viewModel = GameListViewModel()
    @State private var showSearch = false
    
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
                
                VStack(spacing: 0) {
                    // Горизонтальний список жанрів
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Кнопка "All" (скинути фільтр)
                            Button(action: {
                                Task {
                                    await viewModel.filterByGenre(genre: nil)
                                }
                            }) {
                                Text("All")
                                    .font(.subheadline)
                                    .fontWeight(viewModel.selectedGenre == nil ? .bold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedGenre == nil ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(viewModel.selectedGenre == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            // Жанри
                            ForEach(viewModel.availableGenres, id: \.self) { genre in
                                Button(action: {
                                    Task {
                                        await viewModel.filterByGenre(genre: genre)
                                    }
                                }) {
                                    Text(genre.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(viewModel.selectedGenre == genre ? .bold : .regular)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedGenre == genre ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(viewModel.selectedGenre == genre ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                    
                    Divider()
                    
                    // Список ігор
                    ZStack {
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
                        .refreshable { await viewModel.refresh() }
                        
                        if viewModel.isLoading && viewModel.games.isEmpty {
                            LoadingView()
                        }
                        
                        if let error = viewModel.errorMessage, viewModel.games.isEmpty {
                            ErrorView(message: error) {
                                Task { await viewModel.fetchGames() }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
            .task {
                if viewModel.games.isEmpty {
                    await viewModel.fetchGames()
                }
            }
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
