import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchGames(searchQuery: String? = nil, genre: String? = nil, page: Int = 1) async throws -> [Game] {
        //створення запиту
        var urlString = "\(APIConstants.baseURL)/games?key=\(APIConstants.apiKey)&page=\(page)"
        if let querry = searchQuery, !querry.isEmpty {
            urlString += "&search=\(querry)"
        }
        // для фільтрації за жанром
        if let genre = genre, !genre.isEmpty {
                urlString += "&genres=\(genre)"
            }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        //початок виконання запиту
        let (data, response) = try await URLSession.shared.data(from: url)
        
        //перевірка статусу
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Не має відповіді від сервера")
        }
            switch httpResponse.statusCode {
            case 200:
                break
            case 400:
                throw NetworkError.serverError("Неправильний або недійсний запит від клієнта (400)")
            case 401:
                throw NetworkError.serverError("Необхідна автентифікація для доступу до ресурсу (401)")
            case 403:
                throw NetworkError.serverError("Сервер відмовляється виконати запит (заборонено) (403)")
            case 404:
                throw NetworkError.serverError("Сервер не може знайти запитуваний ресурс або документ (404)")
            case 500:
                throw NetworkError.serverError("Внутрішня помилка сервера (500)")
            default:
                throw NetworkError.serverError("Невідома помилка: \(httpResponse.statusCode)")

        }
        //перетворення в JSON
        do {
            let gameResponse = try JSONDecoder().decode(GamesResponse.self, from: data)
            return gameResponse.results
        } catch {
            print("Помилка декодування: \(error)")
            throw NetworkError.decodingError

        }
    }
    
    func fetchGameDetails(id: Int) async throws -> GameDetails {
        let urlString = "\(APIConstants.baseURL)/games/\(id)?key=\(APIConstants.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Не має відповіді від сервера")
        }
            switch httpResponse.statusCode {
            case 200:
                break
            case 400:
                throw NetworkError.serverError("Неправильний або недійсний запит від клієнта (400)")
            case 401:
                throw NetworkError.serverError("Необхідна автентифікація для доступу до ресурсу (401)")
            case 403:
                throw NetworkError.serverError("Сервер відмовляється виконати запит (заборонено) (403)")
            case 404:
                throw NetworkError.serverError("Сервер не може знайти запитуваний ресурс або документ (404)")
            case 500:
                throw NetworkError.serverError("Внутрішня помилка сервера (500)")
            default:
                throw NetworkError.serverError("Невідома помилка: \(httpResponse.statusCode)")

        }
        
        do {
            let gameDetails = try JSONDecoder().decode(GameDetails.self, from: data)
            return gameDetails
        } catch {
            print("Помилка декодування: \(error)")
            throw NetworkError.decodingError
        }
    }
}


