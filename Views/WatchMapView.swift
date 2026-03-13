import SwiftUI
import MapKit

/// Root map view for ENDO watchOS.
/// Two-layer architecture — do not collapse:
///   Layer 1: Map content builder (geo-anchored) — radar rings, ZonePins, UserAnnotation
///   Layer 2: WatchHUDView ZStack overlay (screen-anchored) — time, activity icon, zone status, biometrics
struct WatchMapView: View {
    @Environment(WatchZoneViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            // MARK: Layer 1 — Geographic map
            mapLayer

            // MARK: Layer 2 — Screen HUD (not geo-anchored)
            WatchHUDView(
                zone: viewModel.currentZone,
                biometric: viewModel.currentBiometric,
                activityIconName: viewModel.activityIconName
            )
        }
        .ignoresSafeArea()
        .task {
            await viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Map Layer

    @ViewBuilder
    private var mapLayer: some View {
        @Bindable var vm = viewModel
        Map(position: $vm.cameraPosition) {

            // Inner radar ring — 1.0 mile
            MapCircle(center: viewModel.userCoordinate, radius: 1609)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.endoCyan.opacity(0.2))

            // Outer radar ring — 2.0 miles
            MapCircle(center: viewModel.userCoordinate, radius: 3218)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.endoCyan.opacity(0.1))

            // User position
            UserAnnotation()

            // Zone condition pins
            ForEach(viewModel.zonePins) { pin in
                Annotation("", coordinate: pin.coordinate) {
                    ZonePinAnnotationView(pin: pin)
                }
            }
        }
        .mapStyle(.hybrid)
        .tint(.endoCyan)
    }
}

#Preview {
    WatchMapView()
        .environment(WatchZoneViewModel())
}
