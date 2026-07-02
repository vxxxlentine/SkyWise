import Foundation
import SwiftUI

// MARK: - Model API
struct WeatherResponse: Decodable {
    
    let main: Main
    let weather: [Weather]
    let sys: Sys
    let name: String
    let timezone: Int
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let main: String
}

struct Sys: Decodable {
    let sunrise: TimeInterval
    let sunset: TimeInterval
}




struct ForecastResponse: Decodable {
    let list: [ForecastItem]
}

struct ForecastItem: Decodable {
    let dt_txt: String
    let main: ForecastMain
    let weather: [Weather]
}

struct ForecastMain: Decodable {
    let temp: Double
}

extension ForecastItem {
    func icon(dayPeriod: DayPeriod) -> String {
        let condition = weather.first?.main.lowercased() ?? ""
        switch condition {
        case let s where s.contains("rain"):   return "cloud.rain.fill"
        case let s where s.contains("cloud"):  return "cloud.fill"
        case let s where s.contains("clear"):  return dayPeriod == .night ? "moon.stars.fill" : "sun.max.fill"
        default: return "cloud.fill"
        }
    }
}
