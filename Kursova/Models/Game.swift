import Foundation

struct Game: Codable, Identifiable {
    let id: Int
    let name: String
    let backgroundImage: String?
    let rating: Double
    let released: String?
    let genres: [Genre]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, rating, released, genres
        case backgroundImage = "Background_image"
    }
}

