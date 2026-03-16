import SwiftUI
import MapKit

// MARK: - WatchZoneRingMini
// Compact zone score ring shown in the map HUD. Tap opens WatchZoneCompassView.

struct WatchZoneRingMini: View {
    let score: Int
    let zone: ZoneClassification

    private var zoneColor: Color { zone.color }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.15), lineWidth: 1.5)
                .frame(width: 36, height: 36)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(zoneColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - PersonalMapPin

private struct PersonalMapPin: View {
    let zone: ZoneClassification
    @State private var isPulsing = false

    private var zoneColor: Color { zone.color }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(zoneColor.opacity(0.4), lineWidth: 8)
                .frame(width: 36, height: 36)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
                .animation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: isPulsing
                )
            Circle()
                .fill(zoneColor)
                .frame(width: 16, height: 16)
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
        }
        .onAppear { isPulsing = true }
    }
}

// MARK: - ZoneMapPin (neighborhood)

private struct ZoneMapPin: View {
    let pin: ENDOZonePin

    var body: some View {
        Circle()
            .fill(pin.zone.color.opacity(0.7))
            .frame(width: 10, height: 10)
            .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - WatchMapView
// Three-state view: lock screen → map → compass detail.
// Modeled on AllTrails (right screen), Apple Maps navigation, and Find My.

struct WatchMapView: View {
    @Environment(WatchZoneViewModel.self) private var viewModel

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showLockScreen: Bool = true
    @State private var showCompass: Bool = false

    var body: some View {
        ZStack {
            mapContent
            hudOverlay
        }
        .overlay {
            if showLockScreen {
                WatchLocationLockView(onDismiss: { showLockScreen = false })
                    .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showCompass) {
            WatchZoneCompassView()
                .environment(viewModel)
        }
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onChange(of: viewModel.heartRate) { _, _ in
            if let coord = viewModel.locationService.currentCoordinate {
                cameraPosition = .region(
                    MKCoordinateRegion(center: coord, latitudinalMeters: 3200, longitudinalMeters: 3200)
                )
            }
        }
    }

    // MARK: - Map

    @ViewBuilder
    private var mapContent: some View {
        @Bindable var vm = viewModel
        Map(position: $cameraPosition) {
            ForEach(viewModel.dataStore.neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate) {
                    ZoneMapPin(pin: pin)
                }
            }

            if let personal = viewModel.dataStore.personalPin {
                Annotation("", coordinate: personal.coordinate) {
                    PersonalMapPin(zone: personal.zone)
                }
            }

            UserAnnotation()

            if let coord = viewModel.locationService.currentCoordinate {
                MapCircle(center: coord, radius: 804)
                    .strokeStyle(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(viewModel.zoneColor.opacity(0.4))
                MapCircle(center: coord, radius: 1609)
                    .strokeStyle(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(viewModel.zoneColor.opacity(0.2))
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .ignoresSafeArea()
    }

    // MARK: - HUD Overlay

    private var hudOverlay: some View {
        ZStack {
            topBar
            bottomSheet
            compassRingButton
        }
    }

    // MARK: - Top bar (AllTrails-inspired)

    private var topBar: some View {
        HStack {
            Button(action: { showLockScreen = true }) {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.5))
                        .frame(width: 28, height: 28)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text(Date(), style: .time)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(radius: 4)

            Spacer()

            Button(action: recenterMap) {
                ZStack {
                    Circle()
                        .fill(viewModel.zoneColor)
                        .frame(width: 28, height: 28)
                    Image(systemName: "location.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Bottom sheet (Apple Maps turn-panel inspired)

    private var bottomSheet: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                zoneIconBadge

                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.currentZone.rawValue)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(viewModel.zoneColor)
                    Text(viewModel.dominantSignal)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text(String(format: "%.0f", viewModel.heartRate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("bpm")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    private var zoneIconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(viewModel.zoneColor.opacity(0.2))
                .frame(width: 32, height: 32)
            Image(systemName: zoneIconName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(viewModel.zoneColor)
        }
    }

    // MARK: - Compass ring (right-center, tap to open detail)

    private var compassRingButton: some View {
        Button(action: { showCompass = true }) {
            WatchZoneRingMini(score: viewModel.compositeScore, zone: viewModel.currentZone)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .offset(x: 50)
    }

    // MARK: - Helpers

    private var zoneIconName: String {
        switch viewModel.currentZone {
        case .supportive: return "checkmark.circle.fill"
        case .moderate:   return "exclamationmark.circle.fill"
        case .hostile:    return "xmark.circle.fill"
        }
    }

    private func recenterMap() {
        guard let coord = viewModel.locationService.currentCoordinate else { return }
        cameraPosition = .region(
            MKCoordinateRegion(center: coord, latitudinalMeters: 1600, longitudinalMeters: 1600)
        )
    }
}

#Preview {
    WatchMapView()
        .environment(WatchZoneViewModel())
}
