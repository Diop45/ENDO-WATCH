import CoreLocation
import Foundation

struct DerivedBioContext: Sendable {
    let coordinate: CLLocationCoordinate2D
    let aqi: Int
    let heatIndex: Double
    let noiseDB: Double

    var expectedHRDelta: Int {
        guard aqi > 100 else { return 0 }
        return min(
            Int((Double(aqi - 100) / 10.0) * 5.5),
            22)
    }

    var expectedHRVSuppression: Double {
        guard aqi > 50 else { return 0 }
        return min(
            (Double(aqi - 50) / 10.0) * 3.2,
            28.0)
    }

    var heatHRDelta: Int {
        guard heatIndex > 90 else { return 0 }
        return min(
            Int((heatIndex - 90) / 10.0 * 10),
            30)
    }

    var expectedHR: Int {
        72 + expectedHRDelta + heatHRDelta
    }

    var expectedHRV: Double {
        let base = 55.0
        let aqiReduction =
            base * (expectedHRVSuppression / 100.0)
        let noiseReduction = noiseDB > 70
            ? (noiseDB - 70) * 0.2 : 0
        return max(
            base - aqiReduction - noiseReduction,
            18.0)
    }

    var expectedHRDisplay: String {
        "\(expectedHR) bpm"
    }

    var expectedHRVDisplay: String {
        String(format: "%.0f ms", expectedHRV)
    }

    var hrDeltaDisplay: String {
        let delta = expectedHRDelta + heatHRDelta
        guard delta > 0 else {
            return "Normal"
        }
        return "+\(delta) bpm expected"
    }

    var hrvSuppressionDisplay: String {
        guard expectedHRVSuppression > 0
        else { return "Normal" }
        return String(
            format: "-%.0f%% expected",
            expectedHRVSuppression)
    }
}
