import SwiftUI
import Combine
import CoreLocation

enum WeatherAnimation {
    case rain, snow, thunder, cloud, sun, moon, none
}

// MARK: - Main Screen

struct WeatherView: View {

    @StateObject var vm = WeatherViewModel()
    @StateObject var locationManager = LocationManager()

    @State private var city = UserDefaults.standard.string(forKey: "lastCity") ?? ""
    
    private var gradientColors: [Color] {
        switch vm.dayPeriod {
        case .morning: return [Color(hex: "FF9A5C"), Color(hex: "C0678A")]
        case .day:     return [Color(hex: "6FA8DC"), Color(hex: "3D6FA0")]
        case .evening: return [Color(hex: "FF6B35"), Color(hex: "2C1654")]
        case .night:   return [Color(hex: "1C1C2E"), Color(hex: "0A0A12")]
        }
    }

    private var weatherAnimation: WeatherAnimation {
        switch vm.condition.lowercased() {
        case let s where s.contains("thunderstorm"): return .thunder
        case let s where s.contains("rain"):         return .rain
        case let s where s.contains("snow"):         return .snow
        case let s where s.contains("cloud"):        return .cloud
        case let s where s.contains("clear"):        return vm.dayPeriod == .night ? .moon : .sun
        default:                                     return .none
        }
    }

    var body: some View {
        ZStack {

            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeOut(duration: 1.5), value: vm.dayPeriod)

            
            VStack(spacing: 27) {

                Text(vm.cityName.isEmpty ? city : vm.cityName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .tracking(2)
                    .textCase(.uppercase)

                Text("\(Int(vm.temp.rounded()))°C")
                    .font(.system(size: 96, weight: .thin))
                    .foregroundStyle(.white)

                Text(vm.condition)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
                
                switch weatherAnimation {
                case .rain:    RainView().frame(height: 50)
                case .snow:    SnowView().frame(height: 50)
                case .thunder: ThunderView().frame(height: 50)
                case .cloud:   CloudView().frame(height: 50)
                case .sun:     SunView().frame(height: 50)
                case .moon:    MoonView().frame(height: 50)
                case .none:    EmptyView()
                }

                    HStack {
                        ForEach(vm.forecast.prefix(5), id: \.dt_txt) { item in
                            ForecastCardView(
                                time: item.dt_txt,
                                icon: item.icon(dayPeriod: vm.dayPeriod),
                                temp: Int(item.main.temp),
                                timezoneOffset: vm.timezone
                            )
                        }
                    }
                .frame(height: 170)
                
                if vm.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                // MARK: - Location Search Button

                Button(action: {
                    locationManager.requestLocation()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                        Text("From my location")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
                            )
                    )
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)

                // MARK: - Search Bar

                HStack(spacing: 12) {
                    Image(systemName: "globe.desk.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 18, weight: .medium))

                    TextField("Search city...", text: $city)
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .overlay(
                            Group {
                                if city.isEmpty {
                                    Text("Search city...")
                                        .foregroundColor(.white.opacity(0.4))
                                        .font(.system(size: 18))
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .leading
                        )

                    if !city.isEmpty {
                        Button(action: { city = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 40)

                // MARK: - Search Button

                Button(action: {
                    UserDefaults.standard.set(city, forKey: "lastCity")
                    Task {
                        await vm.loadAllWeatherData(for:
                                .city(city))
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                        Text("Show weather")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
                            )
                    )
                }
                .padding(.horizontal, 40)

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .task {
            guard !city.isEmpty else { return }
            await vm.loadAllWeatherData(for:
                    .city(city))
        }
        .refreshable {
            await vm.loadAllWeatherData(for:
                    .city(city))
        }
        .onChange(of: locationManager.location) { newLocation in
            guard let coord = newLocation else { return }
            Task {
                await vm.fetchWeather(for: .coordinates(lat: coord.latitude, lon: coord.longitude))
                await vm.fetchForecast(for: .coordinates(lat: coord.latitude, lon: coord.longitude))
                self.city = ""
            }
        }
        .onChange(of: locationManager.denied) { denied in
            if denied {
                vm.errorMessage = "Location access denied"
            }
        }
    }
    
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


#Preview {
    WeatherView()
}
