import Foundation

struct NOAAPointProperties: Codable, Sendable {
    let gridId: String
    let gridX: Int
    let gridY: Int
    let forecast: String
    let forecastHourly: String

    enum CodingKeys: String, CodingKey {
        case gridId
        case gridX
        case gridY
        case forecast
        case forecastHourly
    }
}
