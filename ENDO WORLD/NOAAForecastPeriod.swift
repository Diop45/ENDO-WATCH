import Foundation

struct NOAAForecastPeriod: Codable, Sendable {
    let number: Int
    let name: String
    let temperature: Int
    let temperatureUnit: String
    let relativeHumidity: NOAAHumidity?
    let shortForecast: String
    let detailedForecast: String

    enum CodingKeys: String, CodingKey {
        case number
        case name
        case temperature
        case temperatureUnit
        case relativeHumidity
        case shortForecast
        case detailedForecast
    }
}
