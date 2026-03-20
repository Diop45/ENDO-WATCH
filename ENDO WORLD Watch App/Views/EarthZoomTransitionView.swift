import SwiftUI
import MapKit
import CoreLocation
import WatchKit

// MARK: - Status text sequence (spec)

private let earthZoomStatusSequence: [String] = [
    "Scanning your block",
    "Reading air quality",
    "Checking biometrics",
    "Classifying zone"
]

// MARK: - EarthZoomViewModel

@Observable
@MainActor
final class EarthZoomViewModel {
    enum Phase {
        case globe
        case zooming
        case resolving
        case complete
    }

    var phase: Phase = .globe
    var globeScale: Double = 1.0
    var globeOpacity: Double = 1.0
    var mapOpacity: Double = 0.0
    var hudOpacity: Double = 0.0
    var promptOpacity: Double = 0.0
    var dotPulse: Bool = false
    var statusIndex: Int = 0

    func start() {
        withAnimation(.easeIn(duration: 0.6)) {
            promptOpacity = 1.0
        }
        dotPulse = true

        // Cycle status text every ~1.4s
        for i in 1..<earthZoomStatusSequence.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.4) { [weak self] in
                Task { @MainActor in
                    guard let self else { return }
                    if self.phase != .complete {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.statusIndex = i
                        }
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                withAnimation(.easeIn(duration: 2.5)) {
                    self.globeScale = 12.0
                    self.promptOpacity = 0.0
                }
                self.phase = .zooming
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.phase = .resolving
                withAnimation(.easeInOut(duration: 1.5)) {
                    self.globeOpacity = 0.0
                    self.mapOpacity = 1.0
                    self.hudOpacity = 1.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.phase = .complete
                WKInterfaceDevice.current().play(.success)
            }
        }
    }
}

// MARK: - City lights (deterministic)

private let earthZoomCityLightPositions: [(Double, Double)] = [
    (65, 55), (72, 60), (58, 58), (80, 48), (85, 55),
    (90, 65), (68, 72), (75, 40), (60, 45), (88, 70),
    (55, 65), (78, 58)
]

private let earthZoomCityLightBrightness: [Double] = [
    0.45, 0.5, 0.4, 0.55, 0.48, 0.42, 0.52, 0.38, 0.5, 0.44,
    0.46, 0.52
]

// MARK: - EarthZoomTransitionView

struct EarthZoomTransitionView: View {
    let onComplete: () -> Void

    @State private var viewModel = EarthZoomViewModel()
    @State private var zoneViewModel = WatchZoneViewModel()
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    )

    private var mapCenter: CLLocationCoordinate2D {
        zoneViewModel.locationService.currentCoordinate
            ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
    }

    private var zoneColor: Color { zoneViewModel.zoneColor }

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0F").ignoresSafeArea()

            // Skip button (top left)
            VStack {
                HStack {
                    Button("Skip") {
                        WKInterfaceDevice.current().play(.success)
                        onComplete()
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "#00E5FF").opacity(0.8))
                    .padding(.leading, 8)
                    .padding(.top, 6)
                    Spacer()
                }
                Spacer()
            }
            .opacity(viewModel.phase == .complete ? 0 : 1)
            .allowsHitTesting(viewModel.phase != .complete)

            // Phase 1 + 2 — Globe
            globeLayer
                .scaleEffect(viewModel.globeScale)
                .animation(.easeIn(duration: 2.5), value: viewModel.globeScale)
                .opacity(viewModel.globeOpacity)

            // Phase 3 — Map
            mapLayer
                .opacity(viewModel.mapOpacity)
                .allowsHitTesting(false)

            // HUD overlay
            hudLayer
                .opacity(viewModel.hudOpacity)
                .allowsHitTesting(false)

            // Phase 1 prompt
            promptLayer
                .opacity(viewModel.promptOpacity)
        }
        .task {
            await zoneViewModel.start()
            viewModel.start()
        }
        .onDisappear { zoneViewModel.stop() }
        .onChange(of: viewModel.phase) { _, new in
            if new == .complete {
                onComplete()
            }
        }
    }

    // MARK: - Globe layer

    private var globeLayer: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: "#0D2137"), Color(hex: "#0A0A0F")],
                center: UnitPoint(x: 0.5, y: 0.6),
                startRadius: 10,
                endRadius: 200
            )
            .ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [
                            Color(hex: "#1A3A2A"),
                            Color(hex: "#0D2137"),
                            Color(hex: "#162840")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 140, height: 140)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(hex: "#00E5FF").opacity(0.4),
                                Color(hex: "#00E5FF").opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 144, height: 144)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#00E5FF").opacity(0.12),
                                .clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)

                continentPath

                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "#FFB800").opacity(earthZoomCityLightBrightness[i]))
                        .frame(width: 2, height: 2)
                        .offset(
                            x: earthZoomCityLightPositions[i].0 - 70,
                            y: earthZoomCityLightPositions[i].1 - 70
                        )
                }

                userLocationDot
                    .offset(x: 10, y: -8)
            }
        }
    }

    private var continentPath: some View {
        Path { p in
            p.move(to: CGPoint(x: 35, y: 50))
            p.addCurve(to: CGPoint(x: 55, y: 90), control1: CGPoint(x: 30, y: 70), control2: CGPoint(x: 45, y: 80))
            p.addCurve(to: CGPoint(x: 40, y: 110), control1: CGPoint(x: 60, y: 100), control2: CGPoint(x: 50, y: 108))
            p.addCurve(to: CGPoint(x: 25, y: 80), control1: CGPoint(x: 28, y: 115), control2: CGPoint(x: 20, y: 95))
            p.closeSubpath()
        }
        .fill(Color(hex: "#1E4A2A").opacity(0.7))
        .frame(width: 140, height: 140)
    }

    private var userLocationDot: some View {
        ZStack {
            Circle()
                .strokeBorder(Color(hex: "#00E5FF").opacity(0.3), lineWidth: 6)
                .frame(width: 20, height: 20)
                .scaleEffect(viewModel.dotPulse ? 1.4 : 1.0)
                .opacity(viewModel.dotPulse ? 0.0 : 0.6)
                .animation(
                    .easeOut(duration: 1.4).repeatForever(autoreverses: false),
                    value: viewModel.dotPulse
                )
            Circle()
                .fill(Color(hex: "#00E5FF"))
                .frame(width: 8, height: 8)
            Circle()
                .fill(.white)
                .frame(width: 3, height: 3)
        }
    }

    // MARK: - Prompt layer

    private var promptLayer: some View {
        VStack(spacing: 6) {
            Spacer()
            VStack(spacing: 4) {
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "#00E5FF"))
                            .frame(width: 20, height: 1.5)
                    }
                }
                Text(earthZoomStatusSequence[min(viewModel.statusIndex, earthZoomStatusSequence.count - 1)])
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "#00E5FF"))
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Map layer

    @MapContentBuilder
    private var earthZoomConditionField: some MapContent {
        if let personal = zoneViewModel.dataStore.personalPin {
            MapCircle(center: personal.coordinate, radius: 120)
                .foregroundStyle(personal.zone.color.opacity(0.08))
                .mapOverlayLevel(level: .aboveRoads)
            MapCircle(center: personal.coordinate, radius: 50)
                .foregroundStyle(personal.zone.color.opacity(0.18))
                .mapOverlayLevel(level: .aboveRoads)
        }
        ForEach(zoneViewModel.conditionFieldPins) { pin in
            MapCircle(center: pin.coordinate, radius: pin.zone.conditionRadius * 2.0)
                .foregroundStyle(pin.zone.color.opacity(0.08))
                .mapOverlayLevel(level: .aboveRoads)
            MapCircle(center: pin.coordinate, radius: pin.zone.conditionRadius * 1.0)
                .foregroundStyle(pin.zone.color.opacity(0.18))
                .mapOverlayLevel(level: .aboveRoads)
            MapCircle(center: pin.coordinate, radius: pin.zone.conditionRadius * 0.35)
                .foregroundStyle(pin.zone.color.opacity(0.35))
                .mapOverlayLevel(level: .aboveRoads)
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition, interactionModes: []) {
            earthZoomConditionField

            MapCircle(center: mapCenter, radius: 804)
                .strokeStyle(style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                .foregroundStyle(zoneColor.opacity(0.35))
                .mapOverlayLevel(level: .aboveRoads)

            MapCircle(center: mapCenter, radius: 1609)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(zoneColor.opacity(0.18))
                .mapOverlayLevel(level: .aboveRoads)

            if let pin = zoneViewModel.dataStore.personalPin {
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    PersonalPinView(zone: pin.zone, isPulsing: .constant(true))
                }
            }

            ForEach(zoneViewModel.dataStore.neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    NeighborhoodPinView(pin: pin)
                }
            }

            UserAnnotation()
        }
        .mapStyle(
            .standard(
                elevation: .realistic,
                emphasis: .muted,
                pointsOfInterest: .excludingAll,
                showsTraffic: false
            )
        )
        .mapControls {}
        .ignoresSafeArea()
    }

    // MARK: - HUD layer

    private var hudLayer: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(Date(), style: .time)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 6)
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(zoneViewModel.currentZone.rawValue)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(zoneViewModel.zoneColor)
                    Text(zoneViewModel.dominantSignal)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Text("\(Int(zoneViewModel.heartRate)) bpm")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(red: 26/255, green: 26/255, blue: 46/255, opacity: 0.92))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }
}
