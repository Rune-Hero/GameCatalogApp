import SwiftUI

struct GameCardView: View {
    let game: Game
    let imageWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(game.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            AsyncImage(url: safeImageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: UIConstants.imageCornerRadius)
                            .fill(Color.gray.opacity(0.25))
                        ProgressView()
                    }
                    .frame(width: imageWidth, height: UIConstants.cardImageHeight)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageWidth, height: UIConstants.cardImageHeight)
                        .clipped()
                        .cornerRadius(UIConstants.imageCornerRadius)

                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: UIConstants.imageCornerRadius)
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
                    .frame(width: imageWidth, height: UIConstants.cardImageHeight)

                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    
                    Text(String(format: "%.1f", game.rating))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primaryText)
                }
                
                if let rel = game.released {
                    Text("Released: \(rel)")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.cardCornerRadius)
                .fill(AppTheme.card))
        .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 4)
    }
    
    var safeImageURL: URL? {
        guard let img = game.backgroundImage else { return nil }
        return URL(string: img.replacingOccurrences(of: "http://", with: "https://"))
    }
}

