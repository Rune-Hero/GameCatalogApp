import Foundation

import Foundation

struct GameDetails: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let backgroundImage: String?
    let rating: Double
    let platforms: [PlatformInfo]?
    let genres: [Genre]?
    let released: String?
    let metacritic: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, rating, platforms, genres, released, metacritic
        case backgroundImage = "background_image"
    }
}

struct PlatformInfo: Codable, Identifiable {
    var id: Int { platform.id }
    let platform: Platform
}

struct Platform: Codable {
    let id: Int
    let name: String
}
