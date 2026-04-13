import CoreLocation
import Foundation
import Observation
import os

private let dataLog = Logger(
    subsystem: "ENDO.WORLD",
    category: "ENDODataService")

@Observable @MainActor
final class ENDODataService {

    private var aqiCache:
        [String: (AirNowObservation, Date)] = [:]
    private var heatCache:
        [String: (Double, Date)] = [:]
    private var cdcCache:
        [String: ([CDCPlacesRecord], Date)] = [:]

    func fetchAQI(
        lat: Double,
        lon: Double
    ) async throws -> AirNowObservation? {
        let key = endoCacheKey(lat, lon)
        if let cached = aqiCache[key],
           Date().timeIntervalSince(cached.1) < 3600
        {
            return cached.0
        }

        if ENDOAPIConfig.airNowKey.isEmpty {
            dataLog.notice(
                "AIRNOW_API_KEY missing; skipping AirNow request.")
            return nil
        }

        let urlStr =
            ENDOAPIConfig.airNowBase
            + "/observation/latLong/current/"
            + "?format=application/json"
            + "&latitude=\(lat)"
            + "&longitude=\(lon)"
            + "&distance=25"
            + "&API_KEY="
            + ENDOAPIConfig.airNowKey

        guard let url = URL(string: urlStr) else {
            return nil
        }

        let (data, response) = try await URLSession.shared
            .data(from: url)
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200
        else {
            dataLog.error(
                "AirNow HTTP failure for lat=\(lat) lon=\(lon)")
            return nil
        }

        let decoder = JSONDecoder()
        let observations = try decoder.decode(
            [AirNowObservation].self,
            from: data)

        let result = observations
            .filter { $0.parameterName == "PM2.5" }
            .first
            ?? observations
            .sorted { $0.aqi > $1.aqi }
            .first

        if let r = result {
            aqiCache[key] = (r, Date())
        }
        return result
    }

    func fetchHeatIndex(
        lat: Double,
        lon: Double
    ) async throws -> Double? {
        let key = endoCacheKey(lat, lon)
        if let cached = heatCache[key],
           Date().timeIntervalSince(cached.1) < 3600
        {
            return cached.0
        }

        let latStr = String(format: "%.4f", lat)
        let lonStr = String(format: "%.4f", lon)
        let pointPath =
            "\(ENDOAPIConfig.noaaBase)/points/\(latStr),\(lonStr)"
        guard let pointURL = URL(string: pointPath) else {
            return nil
        }

        let (pointData, pointResp) =
            try await URLSession.shared.data(from: pointURL)
        guard let ph = pointResp as? HTTPURLResponse,
              ph.statusCode == 200
        else {
            dataLog.error("NOAA points HTTP failure")
            return nil
        }

        let pointResponse = try JSONDecoder().decode(
            NOAAPointResponse.self,
            from: pointData)

        guard let forecastURL = URL(
            string: pointResponse.properties.forecastHourly
        ) else {
            return nil
        }

        let (forecastData, forecastResp) =
            try await URLSession.shared.data(from: forecastURL)
        guard let fh = forecastResp as? HTTPURLResponse,
              fh.statusCode == 200
        else {
            dataLog.error("NOAA hourly forecast HTTP failure")
            return nil
        }

        let forecast = try JSONDecoder().decode(
            NOAAForecastResponse.self,
            from: forecastData)

        guard let current =
            forecast.properties.periods.first
        else { return nil }

        let tempF = Double(current.temperature)
        let humidity = Double(
            current.relativeHumidity?.value ?? 50)

        let hi = rothfuszHeatIndex(
            tempF: tempF,
            humidity: humidity)
        heatCache[key] = (hi, Date())
        return hi
    }

    func fetchCDCPlaces(
        lat: Double,
        lon: Double,
        measure: String
    ) async throws -> CDCPlacesRecord? {
        let key = "\(endoCacheKey(lat, lon))_\(measure)"
        if let cached = cdcCache[key],
           Date().timeIntervalSince(cached.1)
           < ENDOAPIConfig.permanentCacheTTL
        {
            return cached.0.first
        }

        let minLat = lat - 0.25
        let maxLat = lat + 0.25
        let minLon = lon - 0.25
        let maxLon = lon + 0.25

        var components = URLComponents(
            string: ENDOAPIConfig.cdcPlacesBase)
        components?.queryItems = [
            URLQueryItem(
                name: "$where",
                value: "measureid='\(measure)'"
                    + " AND latitude > \(minLat)"
                    + " AND latitude < \(maxLat)"
                    + " AND longitude > \(minLon)"
                    + " AND longitude < \(maxLon)"),
            URLQueryItem(
                name: "datavaluetype",
                value: "Age-adjusted prevalence"),
            URLQueryItem(
                name: "$limit",
                value: "5"),
        ]

        guard let url = components?.url else {
            return nil
        }

        let (data, response) = try await URLSession.shared
            .data(from: url)
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200
        else {
            dataLog.error("CDC PLACES HTTP failure for \(measure)")
            return nil
        }

        let decoder = JSONDecoder()
        let records = try decoder.decode(
            [CDCPlacesRecord].self,
            from: data)

        cdcCache[key] = (records, Date())
        return records.first
    }

    func fetchWeatherAlerts(
        lat: Double,
        lon: Double
    ) async throws -> [NOAAAlertFeature] {
        let latStr = String(format: "%.4f", lat)
        let lonStr = String(format: "%.4f", lon)
        let urlStr =
            ENDOAPIConfig.noaaAlertsBase
            + "?point=\(latStr),\(lonStr)"

        guard let url = URL(string: urlStr) else {
            return []
        }

        let (data, response) = try await URLSession.shared
            .data(from: url)
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 200
        else {
            return []
        }

        let alertResponse = try JSONDecoder().decode(
            NOAAAlertResponse.self,
            from: data)
        return alertResponse.features
    }

    func deriveBioContext(
        coordinate: CLLocationCoordinate2D,
        aqi: Int,
        heatIndex: Double,
        noiseDB: Double = 65
    ) -> DerivedBioContext {
        DerivedBioContext(
            coordinate: coordinate,
            aqi: aqi,
            heatIndex: heatIndex,
            noiseDB: noiseDB)
    }

    func pruneCache() {
        let now = Date()
        aqiCache = aqiCache.filter {
            now.timeIntervalSince($0.value.1) < 3600
        }
        heatCache = heatCache.filter {
            now.timeIntervalSince($0.value.1) < 3600
        }
        cdcCache = cdcCache.filter {
            now.timeIntervalSince($0.value.1)
                < ENDOAPIConfig.permanentCacheTTL
        }
    }
}

private func rothfuszHeatIndex(
    tempF: Double,
    humidity: Double
) -> Double {
    let t = tempF
    let r = humidity
    guard t >= 80 else { return t }
    let hi = -42.379
        + 2.04901523 * t
        + 10.14333127 * r
        - 0.22475541 * t * r
        - 0.00683783 * t * t
        - 0.05481717 * r * r
        + 0.00122874 * t * t * r
        + 0.00085282 * t * r * r
        - 0.00000199 * t * t * r * r
    return max(hi, t)
}

private func endoCacheKey(
    _ lat: Double,
    _ lon: Double
) -> String {
    String(format: "%.2f_%.2f", lat, lon)
}
