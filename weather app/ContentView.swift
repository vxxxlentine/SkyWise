import SwiftUI
import Combine
import CoreLocation

// MARK: - Main Screen

struct WeatherView: View {

    @StateObject var vm = WeatherViewModel()
    @StateObject var locationManager = LocationManager()

    @State private var city = UserDefaults.standard.string(forKey: "lastCity") ?? ""

    var body: some View {
        ZStack {

            LinearGradient(
                colors: vm.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeOut(duration: 1.5), value: vm.dayPeriod)

            VStack(spacing: 18) {

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

                ScrollView(.horizontal) {
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
                }
                .frame(height: 110)

                if vm.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                switch vm.weatherAnimation {
                case .rain:    RainView().frame(height: 200)
                case .snow:    SnowView().frame(height: 200)
                case .thunder: ThunderView().frame(height: 200)
                case .cloud:   CloudView().frame(height: 200)
                case .sun:     SunView().frame(height: 200)
                case .moon:    MoonView().frame(height: 200)
                case .none:    EmptyView()
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
                .padding(.horizontal, 40)

                // MARK: - Search Bar

                HStack(spacing: 12) {
                    Image(systemName: /*"/*magnifyingglass"*/*/ "globe.desk.fill")
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
                        await vm.loadAllWeatherData(for: city)
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
            await vm.loadAllWeatherData(for: city)
        }
        .refreshable {
            await vm.loadAllWeatherData(for: city)
        }
        .onChange(of: locationManager.location) { newLocation in
            guard let coord = newLocation else { return }
            Task {
                await vm.fetchWeatherByLocation(lat: coord.latitude, lon: coord.longitude)
                await vm.fetchForecastByLocation(lat: coord.latitude, lon: coord.longitude)
                self.city = ""
            }
        }
        .onChange(of: locationManager.denied) { denied in
            if denied {
                vm.errorMessage = "Location access denied"
            }
        }
        .onChange(of: locationManager.denied) { denied in
            if !denied {
                if let coord = locationManager.location {
                    Task {
                        await vm.fetchWeatherByLocation(lat: coord.latitude, lon: coord.longitude)
                        await vm.fetchForecastByLocation(lat: coord.latitude, lon: coord.longitude)
                    }
                }
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Weather Animations

struct RainView: View {

    @State private var offsetX: CGFloat = -20

    var body: some View {
        Image(systemName: "cloud.rain.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(0.8))
            .offset(y: offsetX)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetX = 20
                }
            }
    }
}

struct MiniCloudView: View {

    @State private var offsetX: CGFloat = -20

    var body: some View {
        Image(systemName: "cloud.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(0.8))
            .offset(x: offsetX)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetX = 20
                }
            }
    }
}

struct CloudView: View {
    var body: some View {
        ZStack {
            MiniCloudView()
                .scaleEffect(1.0)

            MiniCloudView()
                .scaleEffect(0.7)
                .offset(x: 80, y: 30)

            MiniCloudView()
                .scaleEffect(0.6)
                .offset(x: -90, y: 20)
        }
    }
}

struct SunView: View {

    @State private var scale = 1.0

    var body: some View {
        Image(systemName: "sun.max.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.yellow)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.15
                }
            }
    }
}

struct MoonView: View {

    @State private var offsetX: CGFloat = 30
    @State private var opacity: Double = 0.5

    var body: some View {
        ZStack {
            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.3))
                .offset(x: -60, y: -10)

            Image(systemName: "moon.stars.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.5), radius: 40)
                .offset(x: offsetX)
                .opacity(opacity)

            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.2))
                .offset(x: 50, y: 5)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                offsetX = -30
                opacity = 1.0
            }
        }
    }
}

struct SnowView: View {

    @State private var offsetY: CGFloat = -20
    @State private var opacity: Double = 0.6

    var body: some View {
        Image(systemName: "snowflake")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(opacity))
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetY = 20
                    opacity = 1.0
                }
            }
    }
}

struct ThunderView: View {

    @State private var opacity: Double = 1.0
    @State private var offsetX: CGFloat = -20
    
    var body: some View {
        Image(systemName: "cloud.bolt.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(opacity))
            .offset(x: offsetX)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetX = 20
                    opacity = 0.4
                }
            }
    }
}

//#Preview {
//    WeatherView()
//}
//#Preview("Snow") {
//    ZStack {
//        Color.blue.ignoresSafeArea()
//        SnowView().frame(height: 200)
//    }
//}

//#Preview("Thunder") {
//    ZStack {
//        Color(hex: "2C1654").ignoresSafeArea()
//        ThunderView().frame(height: 200)
//    }
//}

#Preview {
    WeatherView()
}
