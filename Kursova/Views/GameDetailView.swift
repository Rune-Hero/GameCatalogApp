import SwiftUI

// MARK: - HTML Utility
extension String {
    // Функція для очищення тексту від поширених HTML-тегів.
    func cleaningHTMLTags() -> String {
        var text = self
        
        // 1. Заміна тегів, що відповідають за перенесення рядка
        text = text.replacingOccurrences(of: "<br>", with: "\n")
        text = text.replacingOccurrences(of: "</p><p>", with: "\n\n")
        
        // 2. Видалення всіх інших HTML-тегів (залишок)
        let pattern = "<[^>]+>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            text = regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "")
        }
        
        // 3. Додаткове очищення (наприклад, нерозривних пробілів)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - GameDetailView
struct GameDetailView: View {
    let gameId: Int
    @StateObject private var viewModel: GameDetailViewModel
    
    // Ініціалізатор
    init(gameId: Int) {
        self.gameId = gameId
        _viewModel = StateObject(wrappedValue: GameDetailViewModel(gameId: gameId))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity)
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task { await viewModel.fetchGameDetails() }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                    } else if let game = viewModel.gameDetails {
                        
                        // Фото
                        AsyncImage(url: safeURL(for: game.backgroundImage)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth, height: 250)
                                    .clipped()
                            default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: screenWidth, height: 250)
                            }
                        }
                        
                        // Контент
                        VStack(alignment: .leading, spacing: 12) {
                            Text(game.name)
                                .font(.title)
                                .bold()
                            
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", game.rating))
                            }
                            .font(.headline)
                            
                            if let released = game.released {
                                Text("Released: \(released)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if let meta = game.metacritic {
                                Text("Metacritic: \(meta)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            // Опис - тепер очищений від HTML!
                            if let desc = game.description?.cleaningHTMLTags(), !desc.isEmpty {
                                Text(desc)
                                    .font(.body)
                            }
                            
                            // Жанри
                            if let genres = game.genres, !genres.isEmpty {
                                // ДОДАНО ЗАГОЛОВОК
                                Text("Жанри")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
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
                            // Платформи
                            if let platforms = game.platforms, !platforms.isEmpty {
                                // ДОДАНО ЗАГОЛОВОК
                                Text("Платформи")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(platforms) { platformInfo in
                                            Text(platformInfo.platform.name)
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
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchGameDetails()
        }
    }
    
    private func safeURL(for string: String?) -> URL? {
        guard let string = string else { return nil }
        return URL(string: string.replacingOccurrences(of: "http://", with: "https://"))
    }
}
