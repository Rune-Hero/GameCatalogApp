import SwiftUI
import Foundation

struct GameListView: View {
    @StateObject private var viewModel = GameListViewModel()
    
    // Сітка з адаптивними колонками
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.games) { game in
                            NavigationLink(destination: GameDetailView(gameId: game.id)) {
                                GameCardView(game: game)
                            }
                            .buttonStyle(CardButtonStyle())
                            .onAppear {
                                if game.id == viewModel.games.last?.id {
                                    Task { await viewModel.loadMoreGames() }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
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
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { print("Пошук натиснуто") }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                    }
                }
            }
            .task {
                if viewModel.games.isEmpty {
                    await viewModel.fetchGames()
                }
            }
        }
    }
}

// Стиль для кнопки картки
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    GameListView()
}
