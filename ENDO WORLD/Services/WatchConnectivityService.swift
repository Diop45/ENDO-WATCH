import Foundation
import WatchConnectivity
import CoreLocation

@Observable
@MainActor
final class WatchConnectivityService: NSObject {

    static var shared: WatchConnectivityService?
    weak var appState: AppState?

    private var session: WCSession?

    override init() {
        super.init()
        WatchConnectivityService.shared = self
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func updateFromMessage(_ message: [String: Any]) {
        guard let state = appState else { return }
        if let v = message["compositeScore"] as? Int { state.compositeScore = v }
        if let s = message["zone"] as? String,
           let z = ZoneClassification(rawValue: s) { state.zoneClassification = z }
        if let v = message["heartRate"] as? Double { state.heartRate = v }
        if let v = message["hrv"] as? Double { state.hrv = v }
        if let v = message["aqi"] as? Int { state.aqi = v }
        if let v = message["pm25"] as? Double { state.pm25 = v }
        if let v = message["noiseLevel"] as? Double { state.noiseLevel = v }
        if let v = message["dominantSignal"] as? String { state.dominantSignal = v }
        if let lat = message["lat"] as? Double, let lon = message["lon"] as? Double {
            state.userCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            WatchConnectivityService.shared?.updateFromMessage(message)
        }
    }
}
