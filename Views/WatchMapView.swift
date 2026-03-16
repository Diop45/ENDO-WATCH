import SwiftUI
import MapKit

// MARK: - WatchMapView
// Two-layer architecture — do not collapse:
//   Layer 1: Map content builder (geo-anchored) — radar rings, ENDOZonePins, UserAnnotation
//   Layer 2: Screen HUD ZStack overlay (screen-anchored) — time, zone label, live BPM

struct WatchMapView: View {
    @Environment(WatchZoneViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            mapLayer
            hudLayer
        }
        .ignoresSafeArea()
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    // MARK: - Layer 1: Map

    @ViewBuilder
    private var mapLayer: some View {
        @Bindable var vm = viewModel
        Map(position: $vm.cameraPosition) {
            // Inner radar ring — 1 mile, tinted by current zone
            MapCircle(center: viewModel.userCoordinate, radius: 1609)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(viewModel.zoneColor.opacity(0.3))

            // Outer radar ring — 2 miles
            MapCircle(center: viewModel.userCoordinate, radius: 3218)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(viewModel.zoneColor.opacity(0.15))

            UserAnnotation()

            // Neighborhood pins from MapDataStore (anonymous, aggregated)
            ForEach(viewModel.dataStore.neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate) {
                    Circle()
                        .fill(pin.zone.color)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .mapStyle(.hybrid)
        .tint(viewModel.zoneColor)
    }

    // MARK: - Layer 2: Screen HUD

    private var hudLayer: some View {
        VStack {
            // Top — clock, trailing aligned, white
            Text(Date.now, format: .dateTime.hour().minute())
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 10)
                .padding(.top, 6)

            Spacer()

            // Bottom bar — zone label + live BPM
            HStack {
                Text(viewModel.currentZone.rawValue)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(viewModel.zoneColor)

                Spacer()

                Label {
                    Text("\(Int(viewModel.streamService.heartRate)) bpm")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "#FF3B3B"))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#1A1A2E").opacity(0.85))
        }
    }
}

#Preview {
    WatchMapView()
        .environment(WatchZoneViewModel())
}
