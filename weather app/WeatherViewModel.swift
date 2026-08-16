import SwiftUI
import Combine

enum DayPeriod {
    case morning, day, evening, night
}

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var cityName: String = ""
    @Published var temp: Double = 0
    @Published var condition: String = ""
    @Published var dayPeriod: DayPeriod = .day
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var timezone: Int = 0
    @Published var forecast: [ForecastItem] = []
 
    private let service: WeatherServiceProtocol
    
    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }
    
    
    private func updateDayPeriod(sunrise: TimeInterval, sunset: TimeInterval) {
        let currentUTC = Date().timeIntervalSince1970
        let dayLength = sunset - sunrise
        
        self.dayPeriod = switch currentUTC {
        case ..<sunrise:                                              .night
        case sunrise..<(sunrise + dayLength * 0.25):                 .morning
        case (sunrise + dayLength * 0.25)..<(sunset - dayLength * 0.25): .day
        case (sunset - dayLength * 0.25)..<sunset:                   .evening
        default:                                                      .night
        }
    }
    
    private func applyWeather(_ response: WeatherResponse) {
        self.temp = response.main.temp
        self.condition = response.weather.first?.main ?? ""
        self.cityName = response.name
        self.timezone = response.timezone
        updateDayPeriod(sunrise: response.sys.sunrise, sunset: response.sys.sunset)
    }
    
    func fetchWeather(for location: WeatherLocation) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await service.fetchWeather(for: location)
            applyWeather(response)
        } catch {
            errorMessage = "Failed to load weather"
            print("Error:", error)
        }
    }
    
    func fetchForecast(for location: WeatherLocation) async {
        do {
            let response = try await service.fetchForecast(for: location)
            self.forecast = response.list
        } catch {
            print("Forecast error:", error)
        }
    }
    
    func loadAllWeatherData(for location: WeatherLocation) async {
        async let weather: () = fetchWeather(for: location)
        async let forecast: () = fetchForecast(for: location)
        
        _ = await [weather, forecast]
    }
}

enum WeatherIconMapper {
    static func symbol(for condition: String, dayPeriod: DayPeriod) -> String {
        switch condition.lowercased() {
        case let s where s.contains("thunderstorm"): return "cloud.bolt.fill"
        case let s where s.contains("rain"):         return "cloud.rain.fill"
        case let s where s.contains("snow"):         return "snowflake"
        case let s where s.contains("cloud"):        return "cloud.fill"
        case let s where s.contains("clear"):        return dayPeriod == .night ? "moon.stars.fill" : "sun.max.fill"
        default: return "cloud.fill"
        }
    }
}


