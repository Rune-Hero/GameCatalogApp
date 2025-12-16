import Foundation

struct APIConstants {
    static let baseURL = "https://api.rawg.io/api"
    static let apiKey = "a1bccb942b724f859f6de9da7f9af8d0"
}

// MARK: - UI Constants
struct UIConstants {
    static let gridSpacing: CGFloat = 12
    static let gridPadding: CGFloat = 16
    
    static let cardInternalPadding: CGFloat = 24
    
    static let cardImageHeight: CGFloat = 180
    
    static let cardCornerRadius: CGFloat = 14
    static let imageCornerRadius: CGFloat = 10
    static let buttonCornerRadius: CGFloat = 20
    
    static func calculateCardDimensions(screenWidth: CGFloat) -> (cardWidth: CGFloat, imageWidth: CGFloat) {
        let cardWidth = (screenWidth - (gridPadding * 2) - gridSpacing) / 2
        let imageWidth = cardWidth - cardInternalPadding
        return (cardWidth, imageWidth)
    }
}
