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
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearch = true  // ← відкриваємо пошук
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

