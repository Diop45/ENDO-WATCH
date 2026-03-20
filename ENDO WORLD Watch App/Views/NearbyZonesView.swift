import SwiftUI
import CoreLocation
import MapKit

// MARK: - NearbyZonesView
// List of zone clusters sorted by distance. Tap opens Avoid / Go Toward sheet.

struct NearbyZonesView: View {
    let dataStore: MapDataStore
    let locationService: LocationService
    let onSelect: (ENDOZonePin, WatchNavigationService.NavigationIntent) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCluster: ENDOZonePin?
    @State private var showIntentSheet = false

    private var userCoord: CLLocationCoordinate2D {
        locationService.currentCoordinate ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
    }

    private var sortedPins: [ENDOZonePin] {
        let all = [dataStore.personalPin].compactMap { $0 } + dataStore.neighborhoodPins
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        return all.sorted { a, b in
            userLoc.distance(from: CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude))
                < userLoc.distance(from: CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Nearby Zones")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.vertical, 10)

            List {
                ForEach(sortedPins) { pin in
                    clusterRow(pin: pin)
                        .onTapGesture {
                            selectedCluster = pin
                            showIntentSheet = true
                        }
                }
            }
            .listStyle(.plain)
        }
        .background(Color.endoBackground)
        .sheet(isPresented: $showIntentSheet) {
            if let pin = selectedCluster {
                NavigationIntentSheet(
                    pin: pin,
                    onAvoid: {
                        onSelect(pin, .avoid)
                        dismiss()
                    },
                    onSeek: {
                        onSelect(pin, .seek)
                        dismiss()
                    },
                    onDismiss: { showIntentSheet = false }
                )
            }
        }
    }

    private func clusterRow(pin: ENDOZonePin) -> some View {
        let dist = userCoord.distance(from: pin.coordinate)
        let bearing = bearingString(from: userCoord, to: pin.coordinate)
        return HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(pin.zone.color)
                .frame(width: 2.5, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(pin.zone.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(pin.zone.color)
                Text(formatDistance(dist) + " \(bearing) · \(pin.dominantSignal)")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Text("\(pin.compositeScore)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(pin.zone.color)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }

    private func formatDistance(_ meters: Double) -> String {
        let miles = meters / 1609
        if miles < 0.1 { return "\(Int(meters * 3.281))ft" }
        return String(format: "%.2fmi", miles)
    }

    private func bearingString(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> String {
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        if bearing < -157.5 || bearing >= 157.5 { return "S" }
        if bearing < -112.5 { return "SW" }
        if bearing < -67.5 { return "W" }
        if bearing < -22.5 { return "NW" }
        if bearing < 22.5 { return "N" }
        if bearing < 67.5 { return "NE" }
        if bearing < 112.5 { return "E" }
        if bearing < 157.5 { return "SE" }
        return "S"
    }
}

// MARK: - NavigationIntentSheet

struct NavigationIntentSheet: View {
    let pin: ENDOZonePin
    let onAvoid: () -> Void
    let onSeek: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("What do you want to do?")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            Text("\(pin.zone.rawValue) · \(pin.compositeScore)/100")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.6))

            Button(action: {
                onAvoid()
                dismiss()
            }) {
                Text("Avoid")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.endoRed)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button(action: {
                onSeek()
                dismiss()
            }) {
                Text("Go Toward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.endoCyan)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button("Cancel") {
                onDismiss()
                dismiss()
            }
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.5))
        }
        .padding()
        .background(Color.endoBackground)
    }
}
