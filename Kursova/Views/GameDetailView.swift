import SwiftUI

extension String {
    func cleaningHTMLTags() -> String {
        var text = self
        
        text = text.replacingOccurrences(of: "<br>", with: "\n")
        text = text.replacingOccurrences(of: "</p><p>", with: "\n\n")
        
        let pattern = "<[^>]+>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            text = regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "")
        }
        
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct GameDetailView: View {
    @EnvironmentObject var localStorageService: LocalStorageService
    
    let gameId: Int
    @StateObject private var viewModel: GameDetailViewModel
    
    init(gameId: Int) {
        self.gameId = gameId
        _viewModel = StateObject(wrappedValue: GameDetailViewModel(gameId: gameId))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Text("Error: \(error)").foregroundColor(.red)
                            Button("Retry") {
                                Task { await viewModel.fetchGameDetails() }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                    } else if let game = viewModel.gameDetails {
                        
                        AsyncImage(url: safeURL(for: game.backgroundImage)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: 250)
                                    .clipped()
                                    .onLongPressGesture {
                                        viewModel.saveImageToGallery()
                                    }
                                    .overlay(alignment: .bottomTrailing) {
                                        Text("Long press to save")
                                            .font(.caption2)
                                            .padding(6)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(6)
                                            .padding(8)
                                    }
                            default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: width, height: 250)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(game.name)
                                .font(.title)
                                .bold()
                            
                            HStack {
                                Image(systemName: "star.fill").foregroundColor(.yellow)
                                Text(String(format: "%.1f", game.rating))
                            }
                            .font(.headline)
                            
                            if let released = game.released {
                                Text("Released: \(released)")
                                    .foregroundColor(.gray)
                            }
                            
                            if let meta = game.metacritic {
                                Text("Metacritic: \(meta)")
                                    .foregroundColor(.gray)
                            }
                            
                            if let desc = game.description?.cleaningHTMLTags(), !desc.isEmpty {
                                Text(desc)
                            }
                            
                            if let genres = game.genres, !genres.isEmpty {
                                Text("Genres").font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(genres) { genre in
                                            Text(genre.name)
                                                .font(.caption)
                                                .padding(6)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                            
                            if let platforms = game.platforms, !platforms.isEmpty {
                                Text("Platforms").font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(platforms) { p in
                                            Text(p.platform.name)
                                                .font(.caption)
                                                .padding(6)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .navigationTitle("Game Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.gameDetails != nil {
                    CollectionButton(viewModel: viewModel)
                }
            }
        }
        
        // Простий алерт (успіх/помилка)
        .alert("Photo Library", isPresented: $viewModel.showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveAlertMessage)
        }
        
        // Алерт із кнопкою відкриття налаштувань
        .alert("access required", isPresented: $viewModel.showOpenSettingsAlert) {
            Button("Open settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Скасувати", role: .cancel) {}
        } message: {
            Text(viewModel.saveAlertMessage)
        }
        
        .task {
            await viewModel.fetchGameDetails()
            viewModel.setupCollectionTracking(with: localStorageService)
        }
    }
    
    private func safeURL(for str: String?) -> URL? {
        guard let str = str else { return nil }
        return URL(string: str.replacingOccurrences(of: "http://", with: "https://"))
    }
}

// MARK: - CollectionButton
struct CollectionButton: View {
    @ObservedObject var viewModel: GameDetailViewModel
    @EnvironmentObject var localStorageService: LocalStorageService
    
    var body: some View {
        Button {
            viewModel.toggleCollectionStatus(in: localStorageService)
        } label: {
            HStack {
                Image(systemName: viewModel.isInCollection ? "star.fill" : "star")
            }
            .padding(6)
            .background(viewModel.isInCollection ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
            .foregroundColor(viewModel.isInCollection ? .white : .primary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
