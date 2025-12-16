import SwiftUI
import Foundation

struct GameListView: View {
    @StateObject private var viewModel = GameListViewModel()
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let dimensions = UIConstants.calculateCardDimensions(screenWidth: geometry.size.width)
                
                let columns = [
                    GridItem(.adaptive(minimum: dimensions.cardWidth), spacing: UIConstants.gridSpacing)
                ]
                
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if !viewModel.selectedGenres.isEmpty {
                                Button(action: {
                                    Task {
                                        await viewModel.clearGenres()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Clear")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(UIConstants.buttonCornerRadius)
                                }
                            }
                            
                            ForEach(viewModel.availableGenres, id: \.self) { genre in
                                Button(action: {
                                    Task {
                                        await viewModel.toggleGenre(genre)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text(genre.capitalized)
                                        
                                        if viewModel.selectedGenres.contains(genre) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                        }
                                    }
                                    .font(.subheadline)
                                    .fontWeight(viewModel.selectedGenres.contains(genre) ? .bold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedGenres.contains(genre) ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(viewModel.selectedGenres.contains(genre) ? .white : .primary)
                                    .cornerRadius(UIConstants.buttonCornerRadius)
                                }
                            }
                        }
                        .padding(.horizontal, UIConstants.gridPadding)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                    
                    if !viewModel.selectedGenres.isEmpty {
                        HStack {
                            Text("\(viewModel.selectedGenres.count) genre(s) selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, UIConstants.gridPadding)
                        .padding(.bottom, 4)
                    }
                    
                    Divider()
                    
                    ZStack {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.games) { game in
                                    NavigationLink(destination: GameDetailView(gameId: game.id)) {
                                        GameCardView(game: game, imageWidth: dimensions.imageWidth)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                    .onAppear {
                                        if game.id == viewModel.games.last?.id {
                                            Task { await viewModel.loadMoreGames() }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, UIConstants.gridPadding)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                Task {
                                    await viewModel.changeSortOption(to: option)
                                }
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            if viewModel.sortOption != .none {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
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

