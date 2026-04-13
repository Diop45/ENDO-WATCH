import Foundation

/// API endpoints and refresh policy.
/// Set `AIRNOW_API_KEY` in the app target Info (or xcconfig → INFOPLIST_KEY).
struct ENDOAPIConfig {
    static var airNowKey: String {
        Bundle.main.object(
            forInfoDictionaryKey: "AIRNOW_API_KEY"
        ) as? String ?? ""
    }

    static let airNowBase =
        "https://www.airnowapi.org/aq"

    static let noaaBase =
        "https://api.weather.gov"

    static let cdcPlacesBase =
        "https://chronicdata.cdc.gov"
        + "/resource/cwsq-ngmh.json"

    static let hrsaBase =
        "https://data.hrsa.gov"
        + "/api/search/json"

    static let epaAlertsBase =
        "https://www.airnowapi.org"
        + "/aq/forecast/latLong"

    static let noaaAlertsBase =
        "https://api.weather.gov/alerts/active"

    static let liveRefreshInterval: Double = 3600
    static let alertPollInterval: Double = 300
    static let permanentCacheTTL: Double = 86400 * 30
}
