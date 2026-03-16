import Foundation
import CoreLocation

// MARK: - Response models

struct AirNowResponse: Codable {
    let dateObserved: String
    let reportingArea: String
    let aqi: Int
    let category: AQICategory
    let parameterName: String

    enum CodingKeys: String, CodingKey {
        case dateObserved  = "DateObserved"
        case reportingArea = "ReportingArea"
        case aqi           = "AQI"
        case category      = "Category"
        case parameterName = "ParameterName"
    }

    struct AQICategory: Codable {
        let name: String
        enum CodingKeys: String, CodingKey { case name = "Name" }
    }
}

struct WeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]

    struct MainWeather: Codable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case humidity
        }
    }

    struct WeatherCondition: Codable {
        let description: String
    }
}

struct CDCPlacesRecord: Codable {
    let measureid: String
    let data_value: String
    let locationname: String
}

struct SAMHSAFacility: Codable {
    let name1: String?
}

struct SAMHSAResponse: Codable {
    let facilities: [SAMHSAFacility]?
    let recordCount: Int?

    enum CodingKeys: String, CodingKey {
        case facilities  = "rows"
        case recordCount = "numRowsTotal"
    }
}

struct TIGERWebLayer: Codable {
    let attributes: [String: String]?
}

struct TIGERWebResponse: Codable {
    let results: [TIGERWebLayer]?
}

// MARK: - Environmental Snapshot (output of fetchAll)

struct EnvironmentalSnapshot {
    var aqi: Int            = 0
    var pm25: Double        = 0
    var heatIndex: Double   = 75
    var resourceDensity: Double = 0
    var tractID: String     = ""
    var aqiCategory: String = "Unknown"
    var weatherDescription: String = ""
}

// MARK: - LiveDataService

@Observable
@MainActor
class LiveDataService {

    // Cached session-level data (CDC + SAMHSA don't change intraday)
    private(set) var cdcRecords: [CDCPlacesRecord] = []
    private(set) var samhsaDensity: Double = 0
    private var cdcFetched = false
    private var samhsaFetched = false

    // MARK: - Aggregated fetch

    func fetchAll(coordinate: CLLocationCoordinate2D) async -> EnvironmentalSnapshot {
        async let aqiTask     = fetchAQI(coordinate: coordinate)
        async let weatherTask = fetchWeather(coordinate: coordinate)
        async let tractTask   = fetchCensusTract(coordinate: coordinate)

        let (aqiPair, weather, tract) = await (aqiTask, weatherTask, tractTask)

        if !samhsaFetched {
            samhsaDensity = await fetchSAMHSADensity(coordinate: coordinate)
            samhsaFetched = true
        }

        return EnvironmentalSnapshot(
            aqi: aqiPair.aqi,
            pm25: aqiPair.pm25,
            heatIndex: weather?.heatIndex ?? 75,
            resourceDensity: samhsaDensity,
            tractID: tract,
            aqiCategory: aqiPair.category,
            weatherDescription: weather?.description ?? ""
        )
    }

    // MARK: - 1. EPA AirNow

    func fetchAQI(coordinate: CLLocationCoordinate2D) async -> (aqi: Int, pm25: Double, category: String) {
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        var components = URLComponents(string: "https://www.airnowapi.org/aq/observation/latLong/current/")
        components?.queryItems = [
            .init(name: "latitude",  value: String(lat)),
            .init(name: "longitude", value: String(lon)),
            .init(name: "distance",  value: "5"),
            .init(name: "API_KEY",   value: Config.airNowAPIKey),
            .init(name: "format",    value: "application/json")
        ]
        guard let url = components?.url else { return (0, 0, "Unknown") }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let records = try JSONDecoder().decode([AirNowResponse].self, from: data)
            let pm25Record  = records.first { $0.parameterName.uppercased().contains("PM2.5") }
            let ozoneRecord = records.first { $0.parameterName.uppercased().contains("OZONE") }
            let dominantAQI = max(pm25Record?.aqi ?? 0, ozoneRecord?.aqi ?? 0)
            let pm25Val     = Double(pm25Record?.aqi ?? 0)
            let category    = pm25Record?.category.name ?? ozoneRecord?.category.name ?? "Unknown"
            return (dominantAQI, pm25Val, category)
        } catch {
            return (0, 0, "Unknown")
        }
    }

    // MARK: - 2. OpenWeatherMap

    func fetchWeather(coordinate: CLLocationCoordinate2D) async -> (heatIndex: Double, description: String)? {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            .init(name: "lat",   value: String(coordinate.latitude)),
            .init(name: "lon",   value: String(coordinate.longitude)),
            .init(name: "appid", value: Config.openWeatherAPIKey),
            .init(name: "units", value: "imperial")
        ]
        guard let url = components?.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            let hi = steadmanHeatIndex(tempF: response.main.temp, humidity: Double(response.main.humidity))
            let desc = response.weather.first?.description ?? ""
            return (hi, desc)
        } catch {
            return nil
        }
    }

    // MARK: - 3. CDC PLACES

    func fetchCDCPlaces(city: String) async {
        guard !cdcFetched else { return }
        var components = URLComponents(string: "https://chronicdata.cdc.gov/resource/cwsq-ngmh.json")
        let whereClause = "locationname like '%\(city)%'"
        components?.queryItems = [
            .init(name: "$where", value: whereClause),
            .init(name: "$limit", value: "10")
        ]
        guard let url = components?.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let all = try JSONDecoder().decode([CDCPlacesRecord].self, from: data)
            cdcRecords = all.filter { ["BPHIGH", "DIABETES", "CASTHMA"].contains($0.measureid) }
            cdcFetched = true
        } catch {
            cdcRecords = []
        }
    }

    // MARK: - 4. SAMHSA Treatment Locator

    func fetchSAMHSADensity(coordinate: CLLocationCoordinate2D) async -> Double {
        var components = URLComponents(string: "https://findtreatment.samhsa.gov/locator/search")
        components?.queryItems = [
            .init(name: "sAddr",    value: "\(coordinate.latitude),\(coordinate.longitude)"),
            .init(name: "distance", value: "5"),
            .init(name: "type",     value: "SA,MH")
        ]
        guard let url = components?.url else { return 0 }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(SAMHSAResponse.self, from: data)
            let count = response.recordCount ?? response.facilities?.count ?? 0
            // Normalize: 0 facilities = 0 density, 20+ facilities = 100 density
            return min(Double(count) / 20.0 * 100.0, 100.0)
        } catch {
            return 0
        }
    }

    // MARK: - 5. US Census TIGERweb (tract GEOID)

    func fetchCensusTract(coordinate: CLLocationCoordinate2D) async -> String {
        var components = URLComponents(
            string: "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb/tigerWMS_Current/MapServer/identify"
        )
        components?.queryItems = [
            .init(name: "geometry",     value: "\(coordinate.longitude),\(coordinate.latitude)"),
            .init(name: "geometryType", value: "esriGeometryPoint"),
            .init(name: "layers",       value: "all"),
            .init(name: "returnGeometry", value: "false"),
            .init(name: "f",            value: "json")
        ]
        guard let url = components?.url else { return "" }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TIGERWebResponse.self, from: data)
            return response.results?.first?.attributes?["GEOID"] ?? ""
        } catch {
            return ""
        }
    }
}

// MARK: - Steadman Heat Index formula (private helper)

private func steadmanHeatIndex(tempF: Double, humidity: Double) -> Double {
    guard tempF >= 80, humidity >= 40 else { return tempF }
    let T = tempF, RH = humidity
    return -42.379
        + 2.04901523 * T
        + 10.14333127 * RH
        - 0.22475541 * T * RH
        - 0.00683783 * T * T
        - 0.05481717 * RH * RH
        + 0.00122874 * T * T * RH
        + 0.00085282 * T * RH * RH
        - 0.00000199 * T * T * RH * RH
}
