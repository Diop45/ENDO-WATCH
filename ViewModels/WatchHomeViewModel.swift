import SwiftUI

// MARK: - ScanState

enum ScanState: Equatable {
    case idle
    case scanning
    case success
    case failure
}

// MARK: - WatchHomeViewModel

@Observable
@MainActor
final class WatchHomeViewModel {

    // MARK: - State

    private(set) var scanState:  ScanState  = .idle
    private(set) var lastResult: ScanResult?

    private let scanService = ScanService()

    // MARK: - Init: restore last persisted result

    init() {
        loadPersistedResult()
    }

    // MARK: - Scan

    func beginScan() {
        guard scanState == .idle else { return }
        scanState = .scanning

        Task {
            do {
                let result   = try await scanService.performScan()
                lastResult   = result
                scanState    = .success
                try? await Task.sleep(for: .seconds(1.2))
                if scanState == .success { scanState = .idle }
            } catch {
                scanState = .failure
                try? await Task.sleep(for: .seconds(1.2))
                if scanState == .failure { scanState = .idle }
            }
        }
    }

    // MARK: - AQI tile

    var aqiDisplayValue: String {
        guard let r = lastResult else { return "——" }
        return "\(r.airQualityIndex)"
    }

    var aqiColor: Color {
        guard let r = lastResult else { return Color(hex: "#8E8E93") }
        switch r.airQualityIndex {
        case 0...50:   return Color(hex: "#34C759")
        case 51...100: return Color(hex: "#FFD60A")
        case 101...150: return Color(hex: "#FF9F0A")
        default:       return Color(hex: "#FF453A")
        }
    }

    // MARK: - Zone tile

    var zoneDisplayValue: String { lastResult?.zoneLabel.rawValue ?? "——" }
    var zoneColor: Color         { lastResult?.zoneLabel.color ?? Color(hex: "#8E8E93") }

    // MARK: - Updated tile
    // Recomputed on each view render (the view refreshes every minute via its clock timer).

    var elapsedDisplayValue: String {
        guard let r = lastResult else { return "——" }
        let elapsed = Date().timeIntervalSince(r.timestamp)
        if elapsed < 3600 { return "\(max(1, Int(elapsed / 60)))m" }
        return "\(Int(elapsed / 3600))h"
    }

    // MARK: - Persist reload

    func loadPersistedResult() {
        let defaults = UserDefaults(suiteName: "group.com.endoworld.endo") ?? .standard
        guard
            let data   = defaults.data(forKey: "endo.lastScanResult"),
            let result = try? JSONDecoder().decode(ScanResult.self, from: data)
        else { return }
        lastResult = result
    }
}
