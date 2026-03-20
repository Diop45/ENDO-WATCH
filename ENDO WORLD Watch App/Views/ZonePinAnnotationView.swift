import SwiftUI

struct ZonePinAnnotationView: View {
    let pin: ZonePin

    var body: some View {
        Circle()
            .fill(pin.classification.color.opacity(0.85))
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(pin.classification.color, lineWidth: 1)
            )
            .shadow(color: pin.classification.color.opacity(0.6), radius: 4)
    }
}

#Preview {
    ZonePinAnnotationView(pin: ZonePin(
        coordinate: .init(latitude: 42.33, longitude: -83.04),
        classification: .hostile,
        environmentalScore: 0.72,
        biometricScore: 0.61
    ))
    .background(Color.endoBackground)
}
