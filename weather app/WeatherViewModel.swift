//import SwiftUI
//import Combine
//
////MARK: - ViewModel
//@MainActor
//
//enum DayPeriod {
//    case morning, day, evening, night
//}
//
//class WeatherViewModel: ObservableObject {
//    
//    @Published var sunrise: TimeInterval = 0
//    @Published var sunset: TimeInterval = 0
//    @Published var cityName: String = ""
//    
//    @Published var temp: Double = 0
//    @Published var condition: String = ""
//    @Published var dayPeriod: DayPeriod = .day
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var timezone: Int = 0
//    
//    @Published var forecast: [ForecastItem] = []
//    
//    private let apiKey = "fef5d1a7fdfd62320d4ec0b8bfad2f4f"
//    
//    func fetchWeather(for city: String) async {
//        
//        
//        errorMessage = nil
//        isLoading = true
//        
//        defer {
//            isLoading = false
//        }
//        
//        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
//        
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru"
//        
//        guard let url = URL(string: urlString) else { return }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            
//            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
//            //MARK: 2.0
//            self.temp = response.main.temp
//            self.condition = response.weather.first?.main ?? ""
//            self.sunrise = response.sys.sunrise
//            self.sunset = response.sys.sunset
//            self.cityName = response.name
//            self.timezone = response.timezone
//            
//            let currentUTC = Date().timeIntervalSince1970
//            let sunrise = response.sys.sunrise
//            let sunset = response.sys.sunset
//            let dayLength = sunset - sunrise
//            
//            self.dayPeriod = switch currentUTC {
//            case ..<sunrise: .night
//            case sunrise..<(sunrise + dayLength * 0.25) : .morning
//            case (sunrise + dayLength * 0.25)..<(sunset - dayLength * 0.25): . day
//            case (sunset - dayLength * 0.25)..<sunset: .evening
//            default: .night
//            }
//        } catch {
//                       errorMessage = "Не удалось загрузить погоду"
//                       print("ошибка загрузки: \(error)")
//                   }
//        }
//    
//    
//    //MARK: выучить разобрать
//    func fetchWeatherByLocation(lat: Double, lon: Double) async {
//        errorMessage = nil
//        isLoading = true
//        defer { isLoading = false }
//        
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru"
//        guard let url = URL(string: urlString) else { return }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
//            self.temp = response.main.temp
//            self.cityName = response.name
//            self.condition = response.weather.first?.main ?? ""
////            let current = Date().timeIntervalSince1970
//            self.timezone = response.timezone
//            
//            let currentUTC = Date().timeIntervalSince1970
//            let sunrise = response.sys.sunrise
//            let sunset = response.sys.sunset
//            let dayLength = sunset - sunrise
//            
//            self.dayPeriod = switch currentUTC {
//            case ..<sunrise: .night
//            case sunrise..<(sunrise + dayLength * 0.25) : .morning
//            case (sunrise + dayLength * 0.25)..<(sunset - dayLength * 0.25): . day
//            case (sunset - dayLength * 0.25)..<sunset: .evening
//            default: .night
//        } catch {
//            errorMessage = "Не удалось загрузить погоду"
//            print("Ошибка:", error)
//        }
//    }
//
//    func fetchForecastByLocation(lat: Double, lon: Double) async {
//        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru"
//        guard let url = URL(string: urlString) else { return }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
//            self.forecast = response.list
//        } catch {
//            print("Ошибка прогноза:", error)
//        }
//    }
//    
//    
//    
//    
//    func fetchForecast(for city: String) async {
//
//        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
//        
//        let urlString =
//        "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru"
//
//        guard let url = URL(string: urlString) else { return }
//
//        do {
//
//            let (data, _) = try await URLSession.shared.data(from: url)
//
//            let response = try JSONDecoder().decode(
//                ForecastResponse.self,
//                from: data
//            )
//                self.forecast = response.list
//
//        } catch {
//
//            print("Ошибка прогноза:", error)
//        }
//    }
//    
//    func loadAllWeatherData(for city: String) async {
//        await fetchWeather(for: city)
//        await fetchForecast(for: city)
//    }
//    
//    var gradientColors: [Color] {
//        switch dayPeriod {
//        case .morning: return [Color(hex: "FF9A5C"), Color(hex: "C0678A")]
//        case .day:     return [Color(hex: "6FA8DC"), Color(hex: "3D6FA0")]
//        case .evening: return [Color(hex: "FF6B35"), Color(hex: "2C1654")]
//        case .night:   return [Color(hex: "1C1C2E"), Color(hex: "0A0A12")]
//        }
//    }
//    
//    enum WeatherAnimation {
//        case rain, snow, thunder, cloud, sun, moon, none
//    }
//    
//    var weatherAnimation: WeatherAnimation {
//        switch condition.lowercased() {
//            case let s where s.contains("rain"): return .rain
//            case let s where s.contains("snow"): return .snow
//            case let s where s.contains("thunderstorm"): return .thunder
//            case let s where s.contains("cloud"): return .cloud
//            case let s where s.contains("clear"): return dayPeriod == .night ? .moon : .sun
//            default: return .none
//            }
//    }
//    }
//
//import SwiftUI
//import Combine
//
//enum DayPeriod {
//    case morning, day, evening, night
//}
//
//@MainActor
//class WeatherViewModel: ObservableObject {
//
//    @Published var cityName: String = ""
//    @Published var temp: Double = 0
//    @Published var condition: String = ""
//    @Published var dayPeriod: DayPeriod = .day
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var timezone: Int = 0
//    @Published var forecast: [ForecastItem] = []
//
//private let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
//
//    // MARK: - Приватный метод для расчёта периода суток
//    private func updateDayPeriod(sunrise: TimeInterval, sunset: TimeInterval) {
//        let currentUTC = Date().timeIntervalSince1970
//        let dayLength = sunset - sunrise
//
//        self.dayPeriod = switch currentUTC {
//        case ..<sunrise:                                              .night
//        case sunrise..<(sunrise + dayLength * 0.25):                 .morning
//        case (sunrise + dayLength * 0.25)..<(sunset - dayLength * 0.25): .day
//        case (sunset - dayLength * 0.25)..<sunset:                   .evening
//        default:                                                      .night
//        }
//    }
//
//    // MARK: - Поиск по названию города
//    func fetchWeather(for city: String) async {
//        errorMessage = nil
//        isLoading = true
//        defer { isLoading = false }
//
//        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru")
//        else { return }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
//
//            self.temp = response.main.temp
//            self.condition = response.weather.first?.main ?? ""
//            self.cityName = response.name
//            self.timezone = response.timezone
//
//            updateDayPeriod(sunrise: response.sys.sunrise, sunset: response.sys.sunset)
//        } catch {
//            errorMessage = "Failed to load the weather"
//            print("Ошибка:", error)
//        }
//    }
//
//    // MARK: - Поиск по геолокации
//    func fetchWeatherByLocation(lat: Double, lon: Double) async {
//        errorMessage = nil
//        isLoading = true
//        defer { isLoading = false }
//
//        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru")
//        else { return }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
//
//            self.temp = response.main.temp
//            self.cityName = response.name
//            self.condition = response.weather.first?.main ?? ""
//            self.timezone = response.timezone
//
//            updateDayPeriod(sunrise: response.sys.sunrise, sunset: response.sys.sunset)
//        } catch {
//            errorMessage = "Не удалось загрузить погоду"
//            print("Ошибка:", error)
//        }
//    }
//
//    // MARK: - Прогноз по городу
//    func fetchForecast(for city: String) async {
//        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru")
//        else { return }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
//            self.forecast = response.list
//        } catch {
//            print("Ошибка прогноза:", error)
//        }
//    }
//
//    // MARK: - Прогноз по геолокации
//    func fetchForecastByLocation(lat: Double, lon: Double) async {
//        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru")
//        else { return }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
//            self.forecast = response.list
//        } catch {
//            print("Ошибка прогноза:", error)
//        }
//    }
//
//    // MARK: - Загрузить всё сразу
//    func loadAllWeatherData(for city: String) async {
//        await fetchWeather(for: city)
//        await fetchForecast(for: city)
//    }
//
//    // MARK: - Градиент
//    var gradientColors: [Color] {
//        switch dayPeriod {
//        case .morning: return [Color(hex: "FF9A5C"), Color(hex: "C0678A")]
//        case .day:     return [Color(hex: "6FA8DC"), Color(hex: "3D6FA0")]
//        case .evening: return [Color(hex: "FF6B35"), Color(hex: "2C1654")]
//        case .night:   return [Color(hex: "1C1C2E"), Color(hex: "0A0A12")]
//        }
//    }
//
//    // MARK: - Анимация погоды
//    enum WeatherAnimation {
//        case rain, snow, thunder, cloud, sun, moon, none
//    }
//
//    var weatherAnimation: WeatherAnimation {
//        switch condition.lowercased() {
//        case let s where s.contains("thunderstorm"): return .thunder
//        case let s where s.contains("rain"):         return .rain
//        case let s where s.contains("snow"):         return .snow
//        case let s where s.contains("cloud"):        return .cloud
//        case let s where s.contains("clear"):        return dayPeriod == .night ? .moon : .sun
//        default:                                     return .none
//        }
//    }
//}
//
//extension String {
//    func weatherSymbol(dayPeriod: DayPeriod) -> String {
//        switch self.lowercased() {
//        case let s where s.contains("rain"): return "cloud.rain.fill"
//        case let s where s.contains("cloud"): return "cloud.fill"
//        case let s where s.contains("clear"):
//            switch dayPeriod {
//            case .morning, .day, .evening: return "sun.max.fill"
//            case .night: return "moon.stars.fill"
//            }
//        default: return "cloud.fill"
//        }
//    }
//}
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

    private let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""

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

    func fetchWeather(for city: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru")
        else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)

            self.temp = response.main.temp
            self.condition = response.weather.first?.main ?? ""
            self.cityName = response.name
            self.timezone = response.timezone

            updateDayPeriod(sunrise: response.sys.sunrise, sunset: response.sys.sunset)
        } catch {
            errorMessage = "Failed to load weather"
            print("Error:", error)
        }
    }

    func fetchWeatherByLocation(lat: Double, lon: Double) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru")
        else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)

            self.temp = response.main.temp
            self.cityName = response.name
            self.condition = response.weather.first?.main ?? ""
            self.timezone = response.timezone

            updateDayPeriod(sunrise: response.sys.sunrise, sunset: response.sys.sunset)
        } catch {
            errorMessage = "Failed to load weather"
            print("Error:", error)
        }
    }

    func fetchForecast(for city: String) async {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ru")
        else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
            self.forecast = response.list
        } catch {
            print("Forecast error:", error)
        }
    }

    func fetchForecastByLocation(lat: Double, lon: Double) async {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric&lang=ru")
        else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)
            self.forecast = response.list
        } catch {
            print("Forecast error:", error)
        }
    }

    func loadAllWeatherData(for city: String) async {
        await fetchWeather(for: city)
        await fetchForecast(for: city)
    }

    var gradientColors: [Color] {
        switch dayPeriod {
        case .morning: return [Color(hex: "FF9A5C"), Color(hex: "C0678A")]
        case .day:     return [Color(hex: "6FA8DC"), Color(hex: "3D6FA0")]
        case .evening: return [Color(hex: "FF6B35"), Color(hex: "2C1654")]
        case .night:   return [Color(hex: "1C1C2E"), Color(hex: "0A0A12")]
        }
    }

    enum WeatherAnimation {
        case rain, snow, thunder, cloud, sun, moon, none
    }

    var weatherAnimation: WeatherAnimation {
        switch condition.lowercased() {
        case let s where s.contains("thunderstorm"): return .thunder
        case let s where s.contains("rain"):         return .rain
        case let s where s.contains("snow"):         return .snow
        case let s where s.contains("cloud"):        return .cloud
        case let s where s.contains("clear"):        return dayPeriod == .night ? .moon : .sun
        default:                                     return .none
        }
    }
}

extension String {
    func weatherSymbol(dayPeriod: DayPeriod) -> String {
        switch self.lowercased() {
        case let s where s.contains("rain"): return "cloud.rain.fill"
        case let s where s.contains("cloud"): return "cloud.fill"
        case let s where s.contains("clear"):
            switch dayPeriod {
            case .morning, .day, .evening: return "sun.max.fill"
            case .night: return "moon.stars.fill"
            }
        default: return "cloud.fill"
        }
    }
}
