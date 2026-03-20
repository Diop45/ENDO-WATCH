import SwiftUI

struct SharePromptView: View {

    let pin: ENDOZonePin
    let shareService: AnonymousShareService
    let dataStore: MapDataStore

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 32))
                .foregroundStyle(pin.zone.color)

            Text("Help map your neighborhood.")
                .font(.system(size: 17, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Your zone data is anonymized to block level.\nNo name. No address. No exact location.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Share Anonymously") {
                shareService.userHasOptedIn = true
                Task {
                    await shareService.submitIfOptedIn(pin: pin, dataStore: dataStore)
                }
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(pin.zone.color)

            Button("Not Now") {
                dismiss()
            }
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}
