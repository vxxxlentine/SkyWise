import Foundation

enum WeatherLocation {
    case city(String)
    case coordinates(lat: Double, lon: Double)
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .city(let name):
            return [URLQueryItem(name: "q", value: name)]
        case .coordinates(let lat, let lon):
            return [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon))
            ]
        }
    }
}

protocol WeatherServiceProtocol {
        func fetchWeather(for location: WeatherLocation) async throws -> WeatherResponse
        func fetchForecast(for location: WeatherLocation) async throws -> ForecastResponse
    }
    
final class WeatherService: WeatherServiceProtocol {
        
        private let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
        private let baseURL = "https://api.openweathermap.org/data/2.5"
        
        
        private func buildURL(path: String, location: WeatherLocation) throws -> URL {
            var components = URLComponents(string: "\(baseURL)/\(path)")
            components?.queryItems = location.queryItems + [
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "lang", value: "en")
            ]
            
            guard let url = components?.url else { throw URLError(.badURL) }
            return url
        }
        
        
        func fetchWeather(for location: WeatherLocation) async throws -> WeatherResponse {
            let url = try buildURL(path: "weather", location: location)
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        }
        
        func fetchForecast(for location: WeatherLocation) async throws -> ForecastResponse {
            let url = try buildURL(path: "forecast", location: location)
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(ForecastResponse.self, from: data)
        }
    }
