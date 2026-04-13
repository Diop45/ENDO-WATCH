import Foundation

struct AirNowObservation: Codable, Sendable {
    let dateTime: String
    let reportingArea: String
    let stateCode: String
    let latitude: Double
    let longitude: Double
    let parameterName: String
    let aqi: Int
    let category: AirNowCategory

    enum CodingKeys: String, CodingKey {
        case dateTime = "DateTimeLocal"
        case reportingArea = "ReportingArea"
        case stateCode = "StateCode"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case parameterName = "ParameterName"
        case aqi = "AQI"
        case category = "Category"
    }
}
