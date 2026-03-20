import SwiftUI
import MapKit
import CoreLocation

struct MapTabView: View {
    @Environment(AppState.self) private var appState
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
    )
    @State private var showLayerPicker = false
    @State private var searchText = ""
    @State private var selectedPin: ENDOZonePin?
    @State private var showPinSheet = false
    @State private var neighborhoodPins: [ENDOZonePin] = []
    @State private var personalPin: ENDOZonePin?

    private var mapCenter: CLLocationCoordinate2D {
        appState.userCoordinate ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapLayer
                mapOverlay
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showLayerPicker.toggle() }) {
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: 16))
                            .foregroundStyle(showLayerPicker ? Color.endoCyan : .white)
                    }
                }
            }
            .sheet(isPresented: $showPinSheet) {
                if let pin = selectedPin {
                    PinDetailSheetView(pin: pin, appState: appState, onDismiss: { showPinSheet = false })
                }
            }
        }
        .onAppear {
            loadPins()
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            if let personal = personalPin {
                MapCircle(center: personal.coordinate, radius: 120)
                    .foregroundStyle(personal.zone.color.opacity(0.08))
                    .mapOverlayLevel(level: .aboveRoads)
                MapCircle(center: personal.coordinate, radius: 50)
                    .foregroundStyle(personal.zone.color.opacity(0.18))
                    .mapOverlayLevel(level: .aboveRoads)
            }
            ForEach(neighborhoodPins.prefix(15)) { pin in
                MapCircle(center: pin.coordinate, radius: pin.zone.conditionRadius * 2)
                    .foregroundStyle(pin.zone.color.opacity(0.08))
                    .mapOverlayLevel(level: .aboveRoads)
                MapCircle(center: pin.coordinate, radius: pin.zone.conditionRadius)
                    .foregroundStyle(pin.zone.color.opacity(0.18))
                    .mapOverlayLevel(level: .aboveRoads)
                MapCircle(center: pin.coordinate, radius: pin.zone.conditionRadius * 0.35)
                    .foregroundStyle(pin.zone.color.opacity(0.35))
                    .mapOverlayLevel(level: .aboveRoads)
            }
            MapCircle(center: mapCenter, radius: 804)
                .strokeStyle(style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                .foregroundStyle(appState.zoneClassification.color.opacity(0.35))
                .mapOverlayLevel(level: .aboveRoads)
            MapCircle(center: mapCenter, radius: 1609)
                .strokeStyle(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(appState.zoneClassification.color.opacity(0.18))
                .mapOverlayLevel(level: .aboveRoads)
            if let personal = personalPin {
                Annotation("", coordinate: personal.coordinate, anchor: .center) {
                    Button(action: {
                        selectedPin = personal
                        showPinSheet = true
                    }) {
                        Circle()
                            .fill(personal.zone.color)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
            ForEach(neighborhoodPins) { pin in
                Annotation("", coordinate: pin.coordinate, anchor: .center) {
                    Button(action: {
                        selectedPin = pin
                        showPinSheet = true
                    }) {
                        Circle()
                            .fill(pin.zone.color.opacity(0.72))
                            .frame(width: 10, height: 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
    }

    private var mapOverlay: some View {
        VStack(spacing: 0) {
            TextField("Search a location", text: $searchText)
                .textFieldStyle(.plain)
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
                .padding(.top, 8)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.zoneClassification.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(appState.zoneClassification.color)
                    Text("\(appState.neighborhoodPinCount) reports · 1mi radius")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("\(Int(appState.heartRate)) bpm · AQI \(appState.aqi)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer()
                Button(action: recenter) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.endoCyan)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(16)

            if showLayerPicker {
                HStack(spacing: 8) {
                    layerPill("Bio", Color.endoRed)
                    layerPill("Env", Color.endoCyan)
                    layerPill("Move", Color.endoGreen)
                    layerPill("Urban", Color.endoAmber)
                    layerPill("Patterns", Color.endoPurple)
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Neighborhood · \(appState.zoneClassification.rawValue)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("\(appState.neighborhoodPinCount) reports · 1mi")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("AQI \(appState.aqi)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("PM2.5 \(String(format: "%.1f", appState.pm25))")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("\(Int(appState.noiseLevel)) dB")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(16)
            .background(Color.endoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    private func layerPill(_ label: String, _ color: Color) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .clipShape(Capsule())
    }

    private func recenter() {
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: mapCenter,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
    }

    private func loadPins() {
        let center = appState.userCoordinate ?? CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
        personalPin = ENDOZonePin(
            coordinate: center,
            zone: appState.zoneClassification,
            compositeScore: appState.compositeScore,
            dominantSignal: appState.dominantSignal
        )
        neighborhoodPins = (1...7).map { i in
            let offset = Double(i) * 0.002
            return ENDOZonePin(
                coordinate: CLLocationCoordinate2D(
                    latitude: center.latitude + offset * Double([1, -1, 1, -1, 0, 1, -1][i - 1]),
                    longitude: center.longitude + offset * Double([1, 1, -1, -1, 1, 0, 0][i - 1])
                ),
                zone: [ZoneClassification.supportive, .moderate, .hostile][i % 3],
                compositeScore: 50 + i * 6,
                dominantSignal: ["Air Quality", "Heart Rate", "PM2.5", "Noise", "HRV", "Heat Index", "Resource Density"][i - 1]
            )
        }
    }
}

extension ZoneClassification {
    var conditionRadius: Double {
        switch self {
        case .hostile: return 90
        case .moderate: return 60
        case .supportive: return 70
        }
    }
}

struct PinDetailSheetView: View {
    let pin: ENDOZonePin
    @Bindable var appState: AppState
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(pin.zone.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(pin.zone.color)
                    Text("\(pin.compositeScore)/100 · \(pin.dominantSignal)")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                    HStack(spacing: 8) {
                        SignalBadge(value: "\(appState.aqi)", label: "AQI", color: aqiColor(appState.aqi))
                        SignalBadge(value: String(format: "%.1f", appState.pm25), label: "PM2.5", color: pm25Color(appState.pm25))
                        SignalBadge(value: "\(Int(appState.noiseLevel))dB", label: "Noise", color: Color.endoAmber)
                        SignalBadge(value: "\(Int(appState.heartRate))", label: "HR", color: Color.ouraHR)
                        SignalBadge(value: "\(Int(appState.hrv))", label: "HRV", color: Color.endoCyan)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)

                HStack(spacing: 12) {
                    Button("Avoid this area") {
                        onDismiss()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.endoRed.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Navigate here") {
                        onDismiss()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.endoCyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
            }
            .background(Color.endoBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                        .foregroundStyle(Color.endoCyan)
                }
            }
        }
    }

    private func aqiColor(_ aqi: Int) -> Color {
        aqi <= 50 ? Color.endoGreen : (aqi <= 100 ? Color.endoAmber : Color.endoRed)
    }

    private func pm25Color(_ pm25: Double) -> Color {
        pm25 <= 12 ? Color.endoGreen : (pm25 <= 35.4 ? Color.endoAmber : Color.endoRed)
    }
}
