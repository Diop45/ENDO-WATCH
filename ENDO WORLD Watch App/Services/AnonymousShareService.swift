import Foundation
import CryptoKit
#if os(watchOS)
import WatchKit
#elseif os(iOS)
import UIKit
#endif

// MARK: - AnonymousShareService

@Observable
@MainActor
class AnonymousShareService {

    private enum Keys {
        static let consent  = "endo.shareConsent"
        static let prompted = "endo.sharePrompted"
        static let deviceID = "endo.deviceIdentifier"
    }

    var hasPromptedUser: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.prompted) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.prompted) }
    }

    var userHasOptedIn: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.consent) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.consent) }
    }

    var lastShareTime: Date? {
        get { UserDefaults.standard.object(forKey: "endo.lastShareTime") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "endo.lastShareTime") }
    }

    // Set to true when the prompt should be displayed by the parent view
    var shouldShowPrompt: Bool = false

    // MARK: - Prompt logic

    func promptIfNeeded(after dataStore: MapDataStore) {
        guard dataStore.personalPin != nil else { return }
        guard !hasPromptedUser else { return }

        // Never prompt more than once per 24 hours
        if let last = lastShareTime, Date().timeIntervalSince(last) < 86400 { return }

        shouldShowPrompt = true
        hasPromptedUser = true
    }

    // MARK: - Submission

    func submitIfOptedIn(pin: ENDOZonePin, dataStore: MapDataStore) async {
        guard userHasOptedIn else { return }
        var pinWithHash = pin
        pinWithHash.contributorHash = generateContributorHash()
        await dataStore.submitAnonymousPin(pinWithHash)
        lastShareTime = .now
    }

    // MARK: - Contributor hash (one-way, non-reversible)

    func generateContributorHash() -> String {
        let deviceID = persistentDeviceID()
        let data = Data(deviceID.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Private

    private func persistentDeviceID() -> String {
        if let stored = UserDefaults.standard.string(forKey: Keys.deviceID) {
            return stored
        }
        // Prefer vendor ID on iOS; fall back to a persisted random UUID on watchOS
        let id = vendorIdentifier() ?? UUID().uuidString
        UserDefaults.standard.set(id, forKey: Keys.deviceID)
        return id
    }

    private func vendorIdentifier() -> String? {
        #if os(watchOS)
        return WKInterfaceDevice.current().identifierForVendor?.uuidString
        #elseif os(iOS)
        return UIDevice.current.identifierForVendor?.uuidString
        #else
        return nil
        #endif
    }
}
