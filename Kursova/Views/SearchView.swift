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
                
                let dimensions = UIConstants.calculateCardDimensions(
                    screenWidth: screenWidth
                )
                
                let columns = [
                    GridItem(
                        .adaptive(minimum: dimensions.cardWidth),
                        spacing: UIConstants.gridSpacing
                    )
                ]
                
                ZStack {
                    VStack(spacing: 0) {
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
                        .padding(.horizontal, UIConstants.gridPadding)
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        if viewModel.games.isEmpty && !viewModel.isLoading {
                            VStack(spacing: 20) {
                                Spacer()
                                
                                if searchText.isEmpty {
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
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(viewModel.games) { game in
                                        NavigationLink(destination: GameDetailView(gameId: game.id)) {
                                            GameCardView(
                                                game: game,
                                                imageWidth: dimensions.imageWidth
                                            )
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
                        }
                    }
                    
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if searchText == newValue {
                        performSearch(query: newValue)
                    }
                }
            }
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            viewModel.games = []
            return
        }
        
        guard query.count >= 2 else { return }
        
        Task {
            await viewModel.searchGames(query: query)
        }
    }
}
