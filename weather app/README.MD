# 🌤 SkyWise

A weather app built with SwiftUI, powered by the OpenWeatherMap API. Shows current weather, an hourly forecast, and changes its background based on the time of day in the selected city.

## Features

- Current weather: temperature, condition, description
- Hourly forecast for the upcoming hours
- City search by name (supports non-Latin scripts, e.g. Cyrillic)
- Weather by current location (CoreLocation)
- Animated weather illustrations (rain, snow, thunderstorm, clouds, sun, moon)
- Background changes based on the time of day in the selected region (morning/day/evening/night)
- Remembers the last viewed city

## Tech Stack

- Swift, SwiftUI
- MVVM
- async/await for networking (URLSession)
- CoreLocation for geolocation
- Combine (@Published for UI updates)
- Codable for JSON parsing
- UserDefaults for storing the last city

## Screenshots

<p align="center">
  <img src="screenShots/morning.png" width="210" title="Morning Theme" />
  <img src="screenShots/day.png" width="210" title="Day Theme" />
  <img src="screenShots/evening.png" width="210" title="Evening Theme" />
  <img src="screenShots/night.png" width="210" title="Night Theme" />
</p>

## Setup

1. Clone the repository: `git clone https://github.com/vxxxlentine/SkyWise.git`
2. Open `SkyWise.xcodeproj` in Xcode
3. Add your OpenWeatherMap API key to `Info.plist` under the key `API_KEY`
4. Build and run on a simulator or a device
