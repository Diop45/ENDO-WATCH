import Foundation

struct NOAAForecastProperties: Codable, Sendable {
    let periods: [NOAAForecastPeriod]
}
