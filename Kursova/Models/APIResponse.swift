import Foundation

struct GamesResponse: Codable {
    let count: Int
    let results: [Game]
}
