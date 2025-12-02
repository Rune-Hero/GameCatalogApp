import SwiftUI

struct GameCardView: View {
    let game: Game
    let imageWidth: CGFloat  // ← новий параметр
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Назва гри
            Text(game.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Фото гри
            AsyncImage(url: safeImageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.25))
                        ProgressView()
                    }
                    .frame(width: imageWidth, height: 180)  // ← динамічна ширина

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageWidth, height: 180)  // ← динамічна ширина
                        .clipped()
                        .cornerRadius(10)

                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.25))
                        VStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: imageWidth, height: 180)  // ← динамічна ширина

                @unknown default:
                    EmptyView()
                }
            }

            // Рейтинг + дата релізу
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    
                    Text(String(format: "%.1f", game.rating))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                if let rel = game.released {
                    Text("Released: \(rel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    // http → https
    var safeImageURL: URL? {
        guard let img = game.backgroundImage else { return nil }
        return URL(string: img.replacingOccurrences(of: "http://", with: "https://"))
    }
}

