import SwiftUI

struct MyCollectionView: View {
    
    @EnvironmentObject var localStorageService: LocalStorageService
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            Group {
                if localStorageService.collection.isEmpty {
                    EmptyCollectionPlaceholder()
                } else {
                    List {
                        ForEach(localStorageService.collection) { game in
                            NavigationLink(destination: GameDetailView(gameId: game.id)) {
                                VStack(alignment: .leading) {
                                    Text(game.name)
                                        .font(.headline)
                                    Text("Rating: \(String(format: "%.1f", game.rating))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    localStorageService.removeGame(gameId: game.id)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Collection")
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
        }
    }
    
    private struct EmptyCollectionPlaceholder: View {
        var body: some View {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                Text("Your collection is empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add games from the catalog to see them here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}
