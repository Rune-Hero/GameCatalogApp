import Foundation
import SwiftUI

struct GameCardView: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. Назва гри (вгорі)
            Text(game.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 44)
            
            // 2. Постер гри (по центру)
            AsyncImage(url: URL(string: game.backgroundImage ?? "")) { phase in
                switch phase {
                case .empty:
                    // Стан: завантаження
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                        
                        ProgressView()
                    }
                    .frame(height: 200)
                    
                case .success(let image):
                    // Стан: успішно завантажено
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(8)
                    
                case .failure:
                    // Стан: помилка завантаження
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                        
                        VStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 200)
                    
                @unknown default:
                    EmptyView()
                }
            }
            
            // 3. Рейтинг (внизу)
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                
                Text(String(format: "%.1f", game.rating))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let released = game.released {
                        Text("Released:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(released)
                            .font(.caption)
                            .foregroundColor(.secondary)
                }
                Spacer()
            }
            .frame(width: 200)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Preview для тестування
#Preview {
    GameCardView(game: Game(
        id: 1,
        name: "Grand Theft Auto V",
        backgroundImage: "https://media.rawg.io/media/games/456/456dea5e1c7e3cd07060c14e96612001.jpg",
        rating: 4.5,
        released: "2013-09-17",
        genres: [Genre(id: 4, name: "Action")]
    ))
    .frame(width: 173)
    .padding()
}


