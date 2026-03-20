#if os(iOS)
import SwiftUI
import MapKit

// MARK: - Pin subviews

private struct PersonalPinView: View {
    let pin: ENDOZonePin

    var body: some View {
        ZStack {
            Circle()
                .fill(pin.zone.color.opacity(0.2))
                .frame(width: 44, height: 44)
            Circle()
                .strokeBorder(pin.zone.color, lineWidth: 2)
                .frame(width: 28, height: 28)
            Circle()
                .fill(pin.zone.color)
                .frame(width: 10, height: 10)
        }
    }
}

private struct NeighborhoodPinView: View {
    let pin: ENDOZonePin

    var body: some View {
        Circle()
            .fill(pin.zone.color.opacity(0.5))
            .frame(width: 12, height: 12)
            .overlay(
                Circle().strokeBorder(pin.zone.color, lineWidth: 1)
            )
    }
}

// MARK: - ENDOMapView

struct ENDOMapView: View {

    @State private var cameraPosition: MapCameraPosition = .automatic

    let dataStore: MapDataStore
    let shareService: AnonymousShareService

    var body: some View {
        ZStack(alignment: .bottom) {
            mapContent
            if let pin = dataStore.personalPin {
                pinInfoSheet(pin: pin)
            }
        }
        .sheet(isPresented: Binding(
            get: { shareService.shouldShowPrompt },
            set: { shareService.shouldShowPrompt = $0 }
        )) {
            if let pin = dataStore.personalPin {
                SharePromptView(pin: pin, shareService: shareService, dataStore: dataStore)
            }
        }
        .task {
            if let coord = dataStore.personalPin?.coordinate {
                cameraPosition = .region(
                    MKCoordinateRegion(center: coord, latitudinalMeters: 3200, longitudinalMeters: 3200)
                )
            }
        }
    }

    // MARK: - Map

    private var mapContent: some View {
        Map(position: $cameraPosition) {
            if let pin = dataStore.personalPin {
                Annotation("You", coordinate: pin.coordinate) {
                    PersonalPinView(pin: pin)
                }
            }
            ForEach(dataStore.neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate) {
                    NeighborhoodPinView(pin: pin)
                }
            }
            UserAnnotation()
        }
        .mapStyle(.imagery(elevation: .realistic))
        .ignoresSafeArea()
    }

    // MARK: - Bottom info sheet

    private func pinInfoSheet(pin: ENDOZonePin) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pin.zone.rawValue)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(pin.zone.color)
            Text("Driven by \(pin.dominantSignal)")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Text("\(pin.compositeScore) / 100")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(16)
    }
}
#endif
