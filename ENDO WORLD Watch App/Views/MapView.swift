import SwiftUI
import MapKit
import CoreLocation
import WatchKit

// MARK: - MapView
// Full-screen live map with radar rings, pins, HUD, and sheets per spec.

struct MapView: View {
    @Environment(WatchZoneViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var navService = WatchNavigationService()
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
    @State private var showPinDetail = false
    @State private var showZoneDetail = false
    @State private var showNearbyZones = false
    @State private var showProximityWarning = false
    @State private var showProximityArrival = false
    @State private var selectedPin: ENDOZonePin?
    @State private var warningPin: ENDOZonePin?
    @State private var layerManager = ConditionLayerManager()
    @State private var showLayerPicker = false
    @State private var selectedCluster: ConditionCluster?
    @State private var showClusterDetail = false

    private var mapCenter: CLLocationCoordinate2D {
        viewModel.locationService.currentCoordinate
            ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
    }

    private var dataStore: MapDataStore { viewModel.dataStore }
    private var zoneColor: Color { viewModel.zoneColor }

    var body: some View {
        ZStack {
            mapLayer
            hudLayer
        }
        .overlay(alignment: .trailing) {
            zoneRingButton
                .offset(x: -6)
        }
        .sheet(isPresented: $showPinDetail) {
            if let pin = selectedPin {
                PinDetailSheet(
                    pin: pin,
                    viewModel: viewModel,
                    navService: navService,
                    onDismiss: { showPinDetail = false }
                )
            }
        }
        .sheet(isPresented: $showZoneDetail) {
            ZoneDetailView(viewModel: viewModel)
        }
        .sheet(isPresented: $showNearbyZones) {
            NearbyZonesView(
                dataStore: dataStore,
                locationService: viewModel.locationService,
                onSelect: { pin, intent in
                    navService.start(intent: intent, destination: pin)
                    showNearbyZones = false
                }
            )
        }
        .sheet(isPresented: $showProximityWarning) {
            if let pin = warningPin {
                ProximityWarningView(
                    pin: pin,
                    dominantSignal: viewModel.dominantSignal,
                    navService: navService,
                    onDismiss: { showProximityWarning = false }
                )
            }
        }
        .sheet(isPresented: $showProximityArrival) {
            ProximityArrivalView(
                zone: viewModel.currentZone,
                proximityProgress: max(0, min(1, 1 - navService.distanceToDestination / ZoneNavigationConstants.thresholdMeters)),
                hrBefore: viewModel.heartRate,
                hrNow: viewModel.heartRate,
                onDismiss: { showProximityArrival = false }
            )
        }
        .sheet(isPresented: $showClusterDetail) {
            if let cluster = selectedCluster {
                ClusterDetailSheet(
                    cluster: cluster,
                    viewModel: viewModel,
                    onNavigate: { intent in
                        startNavigation(intent: intent, coordinate: cluster.centerCoordinate, zone: cluster.dominantZone)
                    },
                    onDismiss: { showClusterDetail = false }
                )
            }
        }
        .task {
            navService.setLocationProvider { [viewModel] in viewModel.locationService.currentCoordinate }
            await viewModel.start()
            layerManager.buildClusters(from: dataStore.neighborhoodPins)
        }
        .onDisappear { viewModel.stop(); navService.stop() }
        .onReceive(NotificationCenter.default.publisher(for: .endoProximityThresholdCrossed)) { _ in
            handleProximityCrossed()
        }
        .onChange(of: dataStore.neighborhoodPins) { _, new in
            withAnimation(.easeInOut(duration: 1.5)) {
                layerManager.buildClusters(from: new)
            }
        }
    }

    // MARK: - Map layer

    @MapContentBuilder
    private var conditionFieldLayer: some MapContent {
        if let personal = dataStore.personalPin {
            MapCircle(center: personal.coordinate, radius: 120)
                .foregroundStyle(personal.zone.color.opacity(0.08))
                .mapOverlayLevel(level: .aboveRoads)
            MapCircle(center: personal.coordinate, radius: 50)
                .foregroundStyle(personal.zone.color.opacity(0.18))
                .mapOverlayLevel(level: .aboveRoads)
        }
        ForEach(viewModel.conditionFieldPins) { pin in
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

    @MapContentBuilder
    private var conditionCategoryLayers: some MapContent {
        ForEach(viewModel.conditionFieldPins) { pin in
            let cat = signalToCategory(pin.dominantSignal)
            if layerManager.isVisible(cat) {
                MapCircle(center: pin.coordinate, radius: categoryRadius(cat))
                    .foregroundStyle(categoryColor(cat).opacity(0.12))
                    .mapOverlayLevel(level: .aboveRoads)
                MapCircle(center: pin.coordinate, radius: categoryRadius(cat) * 0.4)
                    .foregroundStyle(categoryColor(cat).opacity(0.28))
                    .mapOverlayLevel(level: .aboveRoads)
            }
        }
    }

    @MapContentBuilder
    private var concentrationClusterOverlays: some MapContent {
        ForEach(layerManager.concentrationClusters) { cluster in
            if layerManager.isVisible(cluster.dominantCategory) {
                MapCircle(center: cluster.centerCoordinate, radius: cluster.radius)
                    .foregroundStyle(categoryColor(cluster.dominantCategory).opacity(0.15))
                    .mapOverlayLevel(level: .aboveRoads)
                MapCircle(center: cluster.centerCoordinate, radius: cluster.radius * 0.3)
                    .foregroundStyle(categoryColor(cluster.dominantCategory).opacity(0.40))
                    .mapOverlayLevel(level: .aboveRoads)
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            // Radar rings (spec: inner 804m dashed 35%, outer 1609m solid 18%)
            MapCircle(center: mapCenter, radius: 804)
                .strokeStyle(style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                .foregroundStyle(zoneColor.opacity(0.35))
                .mapOverlayLevel(level: .aboveRoads)

            MapCircle(center: mapCenter, radius: 1609)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(zoneColor.opacity(0.18))
                .mapOverlayLevel(level: .aboveRoads)

            conditionCategoryLayers
            concentrationClusterOverlays
            conditionFieldLayer

            if let pin = dataStore.personalPin {
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    PersonalPinView(zone: pin.zone, isPulsing: $isPulsing)
                        .onTapGesture {
                            selectedPin = pin
                            showPinDetail = true
                        }
                }
            }

            ForEach(dataStore.neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    NeighborhoodPinView(pin: pin)
                        .onTapGesture {
                            selectedPin = pin
                            showPinDetail = true
                        }
                }
            }

            ForEach(layerManager.concentrationClusters.filter { $0.concentrationScore >= 3 }) { cluster in
                Annotation("", coordinate: cluster.centerCoordinate, anchor: .center) {
                    ConcentrationAnnotationView(cluster: cluster)
                        .onTapGesture {
                            selectedCluster = cluster
                            showClusterDetail = true
                        }
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
        .onMapCameraChange(frequency: .onEnd) { context in
            if let userCoord = viewModel.locationService.currentCoordinate {
                let dist = context.region.center.distance(from: userCoord)
                if dist > 50 { followsUserLocation = false }
            }
        }
    }

    // MARK: - HUD layer

    private var hudLayer: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            if showLayerPicker {
                ConditionLayerPickerView(layerManager: layerManager)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            bottomBar
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.55))
                        .frame(width: 30, height: 30)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()
            Text(Date(), style: .time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()

            Button(action: recenterOnUser) {
                ZStack {
                    Circle()
                        .fill(followsUserLocation ? Color.endoCyan : Color.black.opacity(0.55))
                        .frame(width: 30, height: 30)
                    Image(systemName: followsUserLocation ? "location.fill" : "location")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(followsUserLocation ? .black : .white)
                }
            }
            .buttonStyle(.plain)

            Button(action: { showLayerPicker.toggle() }) {
                ZStack {
                    Circle()
                        .fill(showLayerPicker ? Color(hex: "#00E5FF") : Color.black.opacity(0.55))
                        .frame(width: 28, height: 28)
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(showLayerPicker ? .black : .white)
                }
            }
            .buttonStyle(.plain)

            Button(action: { showNearbyZones = true }) {
                ZStack {
                    Circle()
                        .fill(Color.endoCyan)
                        .frame(width: 30, height: 30)
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }

    private var bottomBar: some View {
        HStack {
            if navService.isNavigating, navService.distanceToDestination > ZoneNavigationConstants.thresholdMeters {
                HStack(spacing: 4) {
                    Image(systemName: navService.activeIntent == .avoid ? "xmark.circle" : "arrow.triangle.turn.up.right.circle")
                        .foregroundStyle(navService.activeIntent == .avoid ? Color.endoRed : Color.endoCyan)
                    Text(formatDistance(navService.distanceToDestination))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(navService.activeIntent == .avoid ? "to avoid" : "to zone")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.6))
                }
            } else {
                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.neighborhoodZone.rawValue)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(viewModel.neighborhoodZone.color)
                    Text("\(viewModel.pinCount) reports · 1mi")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("\(Int(viewModel.heartRate)) bpm")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text("AQI \(viewModel.aqi)")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 26/255, green: 26/255, blue: 46/255, opacity: 0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    private var zoneRingButton: some View {
        Button(action: { showZoneDetail = true }) {
            ZoneRingMini(score: viewModel.compositeScore, zone: viewModel.currentZone)
        }
        .buttonStyle(.plain)
        .frame(maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Helpers

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

    private func formatDistance(_ meters: Double) -> String {
        if meters < 152 { return "\(Int(meters * 3.281))ft" }
        if meters < 1609 { return "\(Int(meters * 3.281 / 10) * 10)ft" }
        return String(format: "%.1fmi", meters / 1609)
    }

    private func handleProximityCrossed() {
        guard let pin = navService.destinationPin else { return }
        warningPin = pin
        if navService.activeIntent == .avoid {
            showProximityWarning = true
        } else if navService.activeIntent == .seek {
            showProximityArrival = true
        }
    }

    private func startNavigation(intent: WatchNavigationService.NavigationIntent, coordinate: CLLocationCoordinate2D, zone: ZoneClassification) {
        let syntheticPin = ENDOZonePin(
            coordinate: coordinate,
            zone: zone,
            compositeScore: zone == .supportive ? 75 : (zone == .moderate ? 50 : 25),
            dominantSignal: "Cluster",
            tractID: "",
            contributorHash: ""
        )
        navService.start(intent: intent, destination: syntheticPin)
        showClusterDetail = false
    }
}

// MARK: - ZoneRingMini (spec)

struct ZoneRingMini: View {
    let score: Int
    let zone: ZoneClassification

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.15), lineWidth: 1.5)
                .frame(width: 36, height: 36)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(zone.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    MapView()
        .environment(WatchZoneViewModel())
}
