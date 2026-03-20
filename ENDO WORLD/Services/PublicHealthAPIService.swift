import Foundation
import CoreLocation

struct EnvironmentalSnapshot {
    var aqi: Int = 0
    var pm25: Double = 0
    var heatIndex: Double = 75
    var humidity: Int = 50
}

@Observable
@MainActor
final class PublicHealthAPIService {

    private var lastFetch: Date = .distantPast
    private let cacheInterval: TimeInterval = 60

    func fetchEnvironmental(coordinate: CLLocationCoordinate2D) async throws -> EnvironmentalSnapshot {
        let now = Date()
        guard now.timeIntervalSince(lastFetch) >= cacheInterval else {
            return EnvironmentalSnapshot(aqi: 48, pm25: 12.4, heatIndex: 75, humidity: 50)
        }
        lastFetch = now
        var snapshot = EnvironmentalSnapshot()
        snapshot.aqi = try await fetchAQI(coordinate: coordinate)
        snapshot.pm25 = try await fetchPM25(coordinate: coordinate)
        let weather = try await fetchWeather(coordinate: coordinate)
        snapshot.heatIndex = weather.heatIndex
        snapshot.humidity = weather.humidity
        return snapshot
    }

    private func fetchAQI(coordinate: CLLocationCoordinate2D) async throws -> Int {
        guard !Config.airNowAPIKey.isEmpty, Config.airNowAPIKey != "YOUR_AIRNOW_API_KEY" else {
            return 48
        }
        let url = URL(string: "https://www.airnowapi.org/aq/observation/latLong/current/?format=application/json&latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&API_KEY=\(Config.airNowAPIKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        struct AirNowRecord: Decodable { let AQI: Int? }
        let records = try JSONDecoder().decode([AirNowRecord].self, from: data)
        return records.first?.AQI ?? 48
    }

    private func fetchPM25(coordinate: CLLocationCoordinate2D) async throws -> Double {
        guard !Config.airNowAPIKey.isEmpty, Config.airNowAPIKey != "YOUR_AIRNOW_API_KEY" else {
            return 12.4
        }
        let url = URL(string: "https://www.airnowapi.org/aq/observation/latLong/current/?format=application/json&latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&API_KEY=\(Config.airNowAPIKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        struct AirNowRecord: Decodable { let ParameterName: String?; let Concentration: Double? }
        let records = try JSONDecoder().decode([AirNowRecord].self, from: data)
        return records.first(where: { $0.ParameterName == "PM2.5" })?.Concentration ?? 12.4
    }

    private func fetchWeather(coordinate: CLLocationCoordinate2D) async throws -> (heatIndex: Double, humidity: Int) {
        guard !Config.openWeatherAPIKey.isEmpty, Config.openWeatherAPIKey != "YOUR_OPENWEATHER_API_KEY" else {
            return (75, 50)
        }
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(Config.openWeatherAPIKey)&units=imperial")!
        let (data, _) = try await URLSession.shared.data(from: url)
        struct Main: Decodable { let temp: Double; let humidity: Int }
        struct Response: Decodable { let main: Main }
        let resp = try JSONDecoder().decode(Response.self, from: data)
        let hi = resp.main.temp + 0.5 * Double(resp.main.humidity) / 100 * resp.main.temp
        return (min(130, max(70, hi)), resp.main.humidity)
    }
}
