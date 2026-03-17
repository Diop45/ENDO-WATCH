import SwiftUI
import MapKit
import CoreLocation

// MARK: - CLLocationCoordinate2D + distance helper

extension CLLocationCoordinate2D {
    func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
}

// MARK: - WatchZoneRingMini
// Compact composite-score arc ring, tap opens WatchZoneCompassView.

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

// MARK: - PersonalPinView
// Multi-ring pulsing annotation at user's current zone location.
// isPulsing is owned by WatchMapView and passed as a Binding so the
// animation survives annotation re-renders without resetting.

struct PersonalPinView: View {
    let zone: ZoneClassification
    @Binding var isPulsing: Bool

    var body: some View {
        ZStack {
            // Outer pulse ring — expands and fades outward
            Circle()
                .strokeBorder(zone.color.opacity(0.35), lineWidth: 10)
                .frame(width: 40, height: 40)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.0 : 0.8)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false),
                    value: isPulsing
                )
            // Mid ring
            Circle()
                .strokeBorder(zone.color.opacity(0.6), lineWidth: 2)
                .frame(width: 24, height: 24)
            // Core dot
            Circle()
                .fill(zone.color)
                .frame(width: 12, height: 12)
            // White center
            Circle()
                .fill(.white)
                .frame(width: 4, height: 4)
        }
        .onAppear { isPulsing = true }
    }
}

// MARK: - NeighborhoodPinView
// Small semi-transparent dot for anonymously-submitted community pins.

struct NeighborhoodPinView: View {
    let pin: ENDOZonePin

    var body: some View {
        ZStack {
            Circle()
                .fill(pin.zone.color.opacity(0.55))
                .frame(width: 10, height: 10)
            Circle()
                .strokeBorder(.white.opacity(0.45), lineWidth: 1)
                .frame(width: 10, height: 10)
        }
    }
}

// MARK: - WatchMapView
// Native MapKit Map with Apple Maps standard tiles, real GPS centering,
// scan radius rings, zone pins, and a screen-anchored biometric HUD.

struct WatchMapView: View {
    @Environment(WatchZoneViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    // .userLocation auto-follows GPS; fallback centers on Detroit.
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    )
    @State private var followsUserLocation = true
    @State private var isPulsing = false
    @State private var showZoneDetail = false
    @State private var showLockScreen = true

    // Current coordinate, falling back to Detroit when GPS not yet available.
    private var mapCenter: CLLocationCoordinate2D {
        viewModel.locationService.currentCoordinate
            ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
    }

    var body: some View {
        ZStack {
            mapLayer
            hudLayer
        }
        .overlay {
            if showLockScreen {
                WatchLocationLockView(onDismiss: { showLockScreen = false })
                    .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showZoneDetail) {
            WatchZoneCompassView()
                .environment(viewModel)
        }
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    // MARK: - Map layer

    @ViewBuilder
    private var mapLayer: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            // Native blue GPS dot — no custom annotation needed.
            UserAnnotation()

            // Inner scan ring — 0.5 mile (804 m), dashed zone-colored.
            MapCircle(center: mapCenter, radius: 804)
                .strokeStyle(style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                .foregroundStyle(viewModel.zoneColor.opacity(0.5))
                .mapOverlayLevel(level: .aboveRoads)

            // Outer scan ring — 1 mile (1609 m), solid zone-colored.
            MapCircle(center: mapCenter, radius: 1609)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(viewModel.zoneColor.opacity(0.25))
                .mapOverlayLevel(level: .aboveRoads)

            // Personal zone pin at precise GPS position.
            if let personal = viewModel.dataStore.personalPin {
                Annotation("", coordinate: personal.coordinate, anchor: .center) {
                    PersonalPinView(zone: personal.zone, isPulsing: $isPulsing)
                }
            }

            // Neighborhood anonymous community pins within 2-mile radius.
            ForEach(viewModel.dataStore.neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    NeighborhoodPinView(pin: pin)
                }
            }
        }
        .mapStyle(
            .standard(
                elevation: .realistic,
                emphasis: .muted,
                pointsOfInterest: .excludingAll,
                showsTraffic: false
            )
        )
        // Disable default MapKit controls — replaced by ENDO HUD.
        .mapControls {}
        .ignoresSafeArea()
        .onMapCameraChange(frequency: .onEnd) { context in
            // Stop following when the user has manually panned > 50 m from GPS.
            if let userCoord = viewModel.locationService.currentCoordinate {
                let distance = context.region.center.distance(from: userCoord)
                if distance > 50 {
                    followsUserLocation = false
                }
            }
        }
    }

    // MARK: - HUD layer (screen-anchored, not geo-anchored)

    private var hudLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            bottomSignalSheet
        }
        .overlay(alignment: .trailing) {
            zoneRingButton
                .offset(x: -6)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(alignment: .center) {
            // Back / dismiss
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.55))
                        .frame(width: 30, height: 30)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Clock — center top
            VStack(spacing: 0) {
                Text(Date(), style: .time)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 1)
            }

            Spacer()

            // Recenter / location button — zone-colored when following
            Button(action: recenterOnUser) {
                ZStack {
                    Circle()
                        .fill(followsUserLocation ? viewModel.zoneColor : .black.opacity(0.55))
                        .frame(width: 30, height: 30)
                    Image(systemName: followsUserLocation ? "location.fill" : "location")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(followsUserLocation ? .black : .white)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }

    // MARK: - Bottom signal sheet

    private var bottomSignalSheet: some View {
        HStack(spacing: 8) {
            // Zone icon badge + classification + dominant signal
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(viewModel.zoneColor.opacity(0.2))
                        .frame(width: 30, height: 30)
                    Image(systemName: zoneSystemIcon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(viewModel.zoneColor)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.currentZone.rawValue)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(viewModel.zoneColor)
                        .lineLimit(1)
                    Text(viewModel.dominantSignal)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Live heart rate + AQI secondary
            VStack(alignment: .trailing, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(viewModel.heartRate))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("bpm")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("AQI \(viewModel.aqi)")
                        .font(.system(size: 9))
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
    }

    // MARK: - Zone ring button (right-center)

    private var zoneRingButton: some View {
        Button(action: { showZoneDetail = true }) {
            WatchZoneRingMini(
                score: viewModel.compositeScore,
                zone: viewModel.currentZone
            )
        }
        .buttonStyle(.plain)
        .frame(maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Helpers

    private var zoneSystemIcon: String {
        switch viewModel.currentZone {
        case .supportive: return "checkmark.circle.fill"
        case .moderate:   return "exclamationmark.circle.fill"
        case .hostile:    return "xmark.circle.fill"
        }
    }

    private func recenterOnUser() {
        followsUserLocation = true
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .userLocation(
                fallback: .region(
                    MKCoordinateRegion(
                        center: viewModel.locationService.currentCoordinate
                            ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
                        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                    )
                )
            )
        }
    }
}

#Preview {
    WatchMapView()
        .environment(WatchZoneViewModel())
}
