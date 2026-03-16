// Config.template.swift
//
// Copy this file to Config.swift, fill in your keys, and build.
// Config.swift is in .gitignore and must NEVER be committed to source control.
//
// Usage in code: Config.airNowAPIKey, Config.openWeatherAPIKey, Config.backendBaseURL

struct Config {
    /// EPA AirNow — https://docs.airnowapi.org
    static let airNowAPIKey      = "YOUR_AIRNOW_API_KEY"

    /// OpenWeatherMap — https://openweathermap.org/api
    static let openWeatherAPIKey = "YOUR_OPENWEATHER_API_KEY"

    /// ENDO backend — receives anonymous zone pins and serves neighborhood aggregates
    static let backendBaseURL    = "https://your-backend.example.com/api"
}
