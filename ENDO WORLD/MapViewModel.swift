import CoreLocation
import Foundation
import MapKit
import SwiftUI
import UIKit

private let kNearbyDistance: Double = 150
private let kRevealDistance: Double = 50
private let kSelectDistance: Double = 20
private let kRevealDismiss: Double = 80

@Observable @MainActor
final class MapViewModel {

    /// Expanding ripple sweep (meters); drives staggered `MapCircle` rings in `MapView`.
    static let scanMaxRadiusMeters: Double = 1609
    static let scanRippleStrideMeters: Double = 235
    static let scanRippleRingCount: Int = 8
    static let scanAnimationDuration: TimeInterval = 2.95

    var position: MapCameraPosition =
        .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 42.3314,
                longitude: -83.0458),
            span: MKCoordinateSpan(
                latitudeDelta: 0.02,
                longitudeDelta: 0.02)))

    var allNodes: [HealthNode] = MockService.nodes()
    var selectedNode: HealthNode?
    var revealNode: HealthNode?
    var sheetState: SheetState = .hidden
    var activeLens: NodeLens = .all
    /// When true, ENDO health nodes and compound pins are shown and tappable.
    var healthLayerOn: Bool = true
    var scanActive: Bool = false
    var scanRadius: Double = 0
    var friendsVisible: Bool = false
    var friends: [ENDOFriend] = MockService.friends()
    var selectedFriend: ENDOFriend?
    var selectedCompound: CompoundNode?
    var nav = NavigationModel()
    var simulator = LocationSimulator()
    var navBannerVisible: Bool = false
    var navBannerZone: ZoneClassification = .moderate

    var navActive: Bool = false
    var navRoute: MKRoute?
    var routePolyline: MKPolyline?
    var navInstruction: String = ""
    var navDest: MKMapItem?

    var zoneBannerVisible: Bool = false
    var zoneBannerZone: ZoneClassification = .moderate
    var zoneBannerSignal: String = ""

    var revealCardVisible: Bool = false

    var missionVisible: Bool = false
    var missionTitle: String = ""
    var missionBody: String = ""

    var userLocation: CLLocationCoordinate2D =
        CLLocationCoordinate2D(
            latitude: 42.3314,
            longitude: -83.0458)

    private var lastZone: ZoneClassification?
    private var revealDismissTask: Task<Void, Never>?
    private var proximityWalkTargetId: String?

    /// When true, the next entry into the nav proximity ring may show
    /// `navBannerVisible`. Reset when leaving the ring or starting a new leg.
    private var navProximityBannerArmed: Bool = true

    /// `Walk Detroit Month` and other `communityChallenge` nodes: opt-in before sheets / proximity.
    var engagedCommunityChallengeNodeIds: Set<String> = []

    /// Tap on a locked challenge opens this invite before `commitNodeSelection`.
    var challengeInviteNodeId: String?

    var radarService = ProximityRadarService()
    var showAnonLayer: Bool = true
    var showRadiusEntryToast: Bool = false
    var entryToastUser: AnonUser?

    var selectedAnonUser: AnonUser?
    var showScanRequestCard: Bool = false
    var scanRequestService = ScanRequestService()
    var activeSession: SharedScanSession?
    var incomingRequest: AnonUser?
    var showIncomingBanner: Bool = false
    var showSharedScanBanner: Bool = false
    var showXPEvent: Bool = false
    var lastXPEvent: Int = 0
    var lastXPWasMutual: Bool = false
    var lastXPWasHostile: Bool = false
    var collectiveBadges: [String: CollectiveScanBadge] = [:]

    var dataService = ENDODataService()
    var liveUpdater: NodeLiveDataUpdater?
    private var liveRefreshTimer: Timer?
    private var ephemeralRefreshTimer: Timer?
    private var didStartLivePipeline = false

    enum SheetState {
        case hidden, preview, expanded
    }

    /// Keeps mock pins on the map if lists were cleared and resets lens when it would hide every node.
    func ensureMapHealthData() {
        if allNodes.isEmpty {
            allNodes = MockService.nodes()
        }
        if friends.isEmpty {
            friends = MockService.friends()
        }
        guard !allNodes.isEmpty else { return }
        let filtered = allNodes.filter { n in
            activeLens == .all
                || n.lenses.contains(activeLens)
        }
        if filtered.isEmpty {
            activeLens = .all
        }
        startLiveDataPipelineIfNeeded()
    }

    func loadNodes() {
        ensureMapHealthData()
        startLiveDataPipelineIfNeeded()
    }

    func startLiveDataPipelineIfNeeded() {
        guard !didStartLivePipeline else { return }
        didStartLivePipeline = true
        liveUpdater = NodeLiveDataUpdater(
            dataService: dataService)
        Task {
            try? await Task.sleep(
                nanoseconds: 2_000_000_000)
            await refreshAllNodes()
        }
        let liveTimer = Timer(
            timeInterval: ENDOAPIConfig.liveRefreshInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshLiveNodes()
            }
        }
        RunLoop.main.add(
            liveTimer,
            forMode: .common)
        liveRefreshTimer = liveTimer

        let ephemTimer = Timer(
            timeInterval: ENDOAPIConfig.alertPollInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshEphemeralNodes()
            }
        }
        RunLoop.main.add(
            ephemTimer,
            forMode: .common)
        ephemeralRefreshTimer = ephemTimer
    }

    func refreshAllNodes() async {
        guard let updater = liveUpdater else { return }
        dataService.pruneCache()
        var updated = allNodes
        for i in updated.indices {
            updated[i] = await updater.updateNode(
                updated[i])
            updated[i].lastRefreshedAt = Date()
        }
        allNodes = updated
        mirrorSelectedNodeFromAllNodes()
    }

    func refreshLiveNodes() async {
        guard let updater = liveUpdater else { return }
        var updated = allNodes
        for i in updated.indices where
            updated[i].type.cadence == .live
        {
            updated[i] = await updater.updateNode(
                updated[i])
            updated[i].lastRefreshedAt = Date()
        }
        allNodes = updated
        mirrorSelectedNodeFromAllNodes()
    }

    func refreshEphemeralNodes() async {
        guard let updater = liveUpdater else { return }
        var updated = allNodes
        for i in updated.indices where
            updated[i].type.cadence == .ephemeral
        {
            updated[i] = await updater.updateNode(
                updated[i])
            updated[i].lastRefreshedAt = Date()
        }
        allNodes = updated
        mirrorSelectedNodeFromAllNodes()
    }

    func refreshNode(_ nodeId: String) async {
        guard let updater = liveUpdater,
              let idx = allNodes.firstIndex(
                where: { $0.id == nodeId })
        else { return }

        allNodes[idx].isLoadingLiveData = true
        mirrorSelectedNodeFromAllNodes()

        var node = allNodes[idx]
        node = await updater.updateNode(node)
        node.isLoadingLiveData = false
        node.lastRefreshedAt = Date()
        allNodes[idx] = node

        if var sel = selectedNode,
           sel.id == nodeId
        {
            sel = node
            selectedNode = sel
        }
    }

    private func mirrorSelectedNodeFromAllNodes() {
        guard let id = selectedNode?.id,
              let fresh = allNodes.first(
                where: { $0.id == id })
        else { return }
        selectedNode = fresh
    }

    static func requiresUserEngagement(_ node: HealthNode) -> Bool {
        node.type == .communityChallenge
    }

    func isLockedCommunityChallenge(_ node: HealthNode) -> Bool {
        Self.requiresUserEngagement(node)
            && !engagedCommunityChallengeNodeIds.contains(node.id)
    }

    var visibleNodes: [HealthNode] {
        allNodes.filter { n in
            activeLens == .all
                || n.lenses.contains(activeLens)
        }
    }

    var compoundNodes: [CompoundNode] {
        CompoundNodeService.buildCompoundNodes(
            from: visibleNodes)
    }

    var standaloneVisibleNodes: [HealthNode] {
        let compounds = compoundNodes
        let hidden = Set(
            compounds.flatMap { $0.constituents.map(\.id) })
        return visibleNodes.filter { !hidden.contains($0.id) }
    }

    /// Hostile-condition nodes within 500m for the ambient strip “NEAR” badge.
    var nearbyHostileNodeCount: Int {
        allNodes.filter { node in
            !node.type.isPositive
                && (node.score ?? 100) < 50
                && distanceBetween(
                    userLocation,
                    node.coordinate) < 500
        }.count
    }

    func bootstrapZone(_ classification: ZoneClassification) {
        if lastZone == nil {
            lastZone = classification
        }
    }

    func fireScan() {
        scanActive = true
        scanRadius = 0
        withAnimation(
            .timingCurve(0.12, 0.88, 0.18, 1.0,
                         duration: Self.scanAnimationDuration)
        ) {
            scanRadius = Self.scanMaxRadiusMeters
        }
        let rippleSettle =
            Self.scanAnimationDuration + 0.18
        DispatchQueue.main.asyncAfter(
            deadline: .now() + rippleSettle
        ) { [weak self] in
            guard let self else { return }
            scanActive = false
            let nodes = MockService.nodes()
            let sorted = nodes.sorted {
                distanceBetween(
                    self.userLocation, $0.coordinate)
                    < distanceBetween(
                        self.userLocation, $1.coordinate)
            }
            for (i, node) in sorted.enumerated() {
                DispatchQueue.main.asyncAfter(
                    deadline: .now()
                        + Double(i) * 0.11
                ) { [weak self] in
                    guard let self else { return }
                    self.allNodes.append(node)
                    if i == sorted.count - 1 {
                        self.proximityWalkTargetId = sorted.first?.id
                    }
                }
            }
            friends = MockService.friends()
        }
    }

    func toggleHealth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            healthLayerOn.toggle()
        }
        if healthLayerOn {
            ensureMapHealthData()
        }
        if healthLayerOn && allNodes.isEmpty {
            fireScan()
        }
    }

    func selectNode(_ node: HealthNode) {
        if Self.requiresUserEngagement(node),
           !engagedCommunityChallengeNodeIds.contains(node.id)
        {
            dismissNode()
            challengeInviteNodeId = node.id
            return
        }
        if let prev = selectedNode, prev.id != node.id {
            setProximity(prev.id, to: .idle)
            if Self.requiresUserEngagement(prev) {
                engagedCommunityChallengeNodeIds.remove(prev.id)
            }
        }
        commitNodeSelection(node)
    }

    func acceptChallengeInvite() {
        guard let id = challengeInviteNodeId,
              let node = allNodes.first(where: { $0.id == id })
        else { return }
        engagedCommunityChallengeNodeIds.insert(id)
        challengeInviteNodeId = nil
        selectNode(node)
    }

    func declineChallengeInvite() {
        withAnimation(.easeOut(duration: 0.2)) {
            challengeInviteNodeId = nil
        }
    }

    private func commitNodeSelection(_ node: HealthNode) {
        setProximity(node.id, to: .selected)
        selectedNode = node
        revealNode = nil
        revealCardVisible = false
        sheetState = .preview
        focusOnLocation(node.coordinate)
        if node.type.cadence == .live
            || node.type.cadence == .ephemeral
        {
            Task {
                await refreshNode(node.id)
            }
        }
    }

    func focusOnLocation(
        _ coordinate: CLLocationCoordinate2D
    ) {
        withAnimation(
            .easeInOut(duration: 0.75)
        ) {
            position = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.016,
                        longitudeDelta: 0.016)))
        }
    }

    func dismissNode() {
        if let n = selectedNode {
            if Self.requiresUserEngagement(n) {
                engagedCommunityChallengeNodeIds.remove(n.id)
            }
            setProximity(n.id, to: .idle)
        }
        selectedNode = nil
        sheetState = .hidden
    }

    func tapMap() {
        challengeInviteNodeId = nil
        dismissNode()
        selectedFriend = nil
        selectedCompound = nil
        revealCardVisible = false
        revealNode = nil
        withAnimation(.easeOut(duration: 0.2)) {
            showScanRequestCard = false
            selectedAnonUser = nil
        }
    }

    func updateProximity() {
        guard healthLayerOn else { return }
        for node in allNodes {
            let dist = distanceBetween(
                userLocation, node.coordinate)
            var newState = proximityState(for: dist)
            if Self.requiresUserEngagement(node),
               !engagedCommunityChallengeNodeIds.contains(node.id)
            {
                newState = .idle
            }
            if nodeProximity(node.id) != newState {
                setProximity(node.id, to: newState)
                handleProximityTransition(
                    node: node,
                    newState: newState,
                    distance: dist)
            }
        }
    }

    func tickSimulatedWalkTowardTarget(stepMeters: Double = 6) {
        guard healthLayerOn,
              let targetId = proximityWalkTargetId,
              let node = allNodes.first(where: { $0.id == targetId })
        else { return }
        let next = coordinate(
            from: userLocation,
            toward: node.coordinate,
            stepMeters: stepMeters)
        userLocation = next
        updateProximity()
        refreshProximityRadar()
    }

    private func proximityState(
        for distance: Double
    ) -> NodeProximityState {
        if distance <= kSelectDistance {
            return .selected
        } else if distance <= kRevealDistance {
            return .autoReveal
        } else if distance <= kNearbyDistance {
            return .nearby
        } else {
            return .idle
        }
    }

    private func handleProximityTransition(
        node: HealthNode,
        newState: NodeProximityState,
        distance: Double
    ) {
        let lockedChallenge =
            Self.requiresUserEngagement(node)
            && !engagedCommunityChallengeNodeIds.contains(
                node.id)

        switch newState {
        case .nearby:
            if lockedChallenge { return }
        case .autoReveal:
            if lockedChallenge { return }
            if selectedNode == nil {
                revealNode = node
                withAnimation(
                    .spring(duration: 0.4, bounce: 0.1)
                ) {
                    revealCardVisible = true
                }
                revealDismissTask?.cancel()
                revealDismissTask = Task {
                    try? await Task.sleep(
                        nanoseconds: 8_000_000_000)
                    if !Task.isCancelled {
                        await MainActor.run {
                            if revealNode?.id == node.id {
                                withAnimation {
                                    revealCardVisible = false
                                    revealNode = nil
                                }
                            }
                        }
                    }
                }
            }
        case .selected:
            if lockedChallenge { return }
            if selectedNode == nil {
                selectNode(node)
            }
        case .idle, .visited:
            if revealNode?.id == node.id,
               distance > kRevealDismiss
            {
                withAnimation {
                    revealCardVisible = false
                    revealNode = nil
                }
            }
        }
    }

    func checkZoneBoundary(
        newZone: ZoneClassification,
        leadingSignal: String
    ) {
        guard let last = lastZone,
              last != newZone
        else {
            lastZone = newZone
            return
        }
        lastZone = newZone
        zoneBannerZone = newZone
        zoneBannerSignal = leadingSignal
        withAnimation(
            .spring(duration: 0.4, bounce: 0.1)
        ) {
            zoneBannerVisible = true
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3.0
        ) { [weak self] in
            guard let self else { return }
            withAnimation(
                .easeIn(duration: 0.3)
            ) {
                self.zoneBannerVisible = false
            }
        }
    }

    func startNav(to dest: MKMapItem) async {
        let destCoord = dest.placemark.coordinate
        let coordinates = [userLocation, destCoord]
        routePolyline = MKPolyline(
            coordinates: coordinates,
            count: coordinates.count)
        navDest = dest
        navActive = true
        navRoute = nil
        navInstruction =
            "Head toward destination"
    }

    func endNav() {
        navActive = false
        navRoute = nil
        routePolyline = nil
        navDest = nil
        navInstruction = ""
    }

    func navigateToNode(_ node: HealthNode) {
        navBannerVisible = false
        navProximityBannerArmed = true
        navBannerZone = ZoneClassification.from(node.score ?? 50)
        Task {
            await nav.startNavigation(
                to: .zone(node),
                from: userLocation)
            if nav.error != nil || nav.polyline == nil {
                return
            }
            if let poly = nav.polyline {
                routePolyline = poly
                navActive = true
                simulator.startSimulation(along: poly)
                userLocation = simulator.currentLocation
                updateNavCameraFollow()
            }
        }
    }

    func navigateToFriend(_ friend: ENDOFriend) {
        navBannerVisible = false
        navProximityBannerArmed = true
        navBannerZone = friend.zone
        Task {
            await nav.startNavigation(
                to: .friend(friend),
                from: userLocation)
            if nav.error != nil || nav.polyline == nil {
                return
            }
            if let poly = nav.polyline {
                routePolyline = poly
                navActive = true
                simulator.startSimulation(along: poly)
                userLocation = simulator.currentLocation
                updateNavCameraFollow()
            }
        }
    }

    func endNavigation() {
        navBannerVisible = false
        navProximityBannerArmed = true
        nav.endNavigation()
        simulator.stopSimulation()
        routePolyline = nil
        endNav()
    }

    func advanceLocationSimulation() {
        guard simulator.isRunning else { return }
        simulator.advance()
        onLocationUpdate(simulator.currentLocation)
    }

    func onLocationUpdate(_ coord: CLLocationCoordinate2D) {
        userLocation = coord

        if nav.isActive,
           let destCoord = nav.destinationCoordinate
        {
            let dist = distanceBetween(coord, destCoord)
            nav.updateDistance(dist)
            nav.updateRouteProgress(simulator.routeProgressFraction)
            nav.updateFacing(
                from: coord,
                simulatorFraction: simulator.routeProgressFraction)

            let proximityMeters: Double = 200

            if let node = nav.destinationNode {
                let nodeDist = distanceBetween(
                    coord, node.coordinate)
                if nodeDist >= proximityMeters {
                    navProximityBannerArmed = true
                } else if nodeDist < proximityMeters,
                          navProximityBannerArmed
                {
                    navProximityBannerArmed = false
                    navBannerZone = ZoneClassification.from(
                        node.score ?? 50)
                    navBannerVisible = true
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 3.0
                    ) { [weak self] in
                        guard let self else { return }
                        withAnimation {
                            self.navBannerVisible = false
                        }
                    }
                }
            } else if let friend = nav.destinationFriend {
                let friendDist = distanceBetween(
                    coord, friend.coordinate)
                if friendDist >= proximityMeters {
                    navProximityBannerArmed = true
                } else if friendDist < proximityMeters,
                          navProximityBannerArmed
                {
                    navProximityBannerArmed = false
                    navBannerZone = friend.zone
                    navBannerVisible = true
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 3.0
                    ) { [weak self] in
                        guard let self else { return }
                        withAnimation {
                            self.navBannerVisible = false
                        }
                    }
                }
            }
            updateNavCameraFollow()
        }

        refreshProximityRadar()
    }

    /// Keeps user and destination in frame while walking the MapKit route.
    func updateNavCameraFollow() {
        guard nav.isActive,
              let dest = nav.destinationCoordinate
        else { return }
        position = .region(
            Self.region(
                user: userLocation,
                destination: dest,
                padding: 1.65))
    }

    /// Hand off walking directions to the Apple Maps app (same MKMapItem route family).
    func openAppleMapsWalkingDirections() {
        guard let dest = nav.destinationCoordinate else { return }
        let start = MKMapItem.forCurrentLocation()
        let end = MKMapItem(
            placemark: MKPlacemark(coordinate: dest))
        MKMapItem.openMaps(
            with: [start, end],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeWalking
            ])
    }

    func pingFriend(_: ENDOFriend) {
        let generator = UIImpactFeedbackGenerator(
            style: .medium)
        generator.impactOccurred()
    }

    func recentre() {
        withAnimation(.spring(duration: 0.5)) {
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 42.3314,
                    longitude: -83.0458),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.015,
                    longitudeDelta: 0.015)))
        }
    }

    func showMission(
        title: String, body: String
    ) {
        missionTitle = title
        missionBody = body
        withAnimation(
            .spring(duration: 0.4, bounce: 0.1)
        ) {
            missionVisible = true
        }
    }

    func dismissMission() {
        withAnimation(.easeIn(duration: 0.25)) {
            missionVisible = false
        }
    }

    // Use case 1: Morning route decision
    func activateMorningRoute() {
        showMission(
            title: "Air quality on your route",
            body:
                "AQI 148 detected on direct path. Clean route via Palmer Park adds 4 min.")
        setProximity("n1", to: .nearby)
        setProximity("n4", to: .nearby)
    }

    // Use case 2: Chronic condition check
    func activateChronicCheck() {
        showMission(
            title: "Environmental stress detected",
            body:
                "Heat 101°F + noise 82dB in your zone. Both exceed thresholds for hypertension.")
        setProximity("n2", to: .nearby)
        setProximity("n3", to: .nearby)
    }

    // Use case 3: Care desert alert
    func activateCareDesertAlert() {
        showMission(
            title: "Care desert zone",
            body:
                "Nearest primary care is 3.8mi. City average is 0.9mi.")
        setProximity("n6", to: .autoReveal)
    }

    // Use case 4: Food desert + disease burden compound
    func activateFoodDiseaseCompound() {
        showMission(
            title: "Compound health condition",
            body:
                "Food desert and diabetes cluster overlap at this block. Structurally linked.")
        setProximity("n7", to: .nearby)
        setProximity("n8", to: .nearby)
    }

    // Use case 5: Route to clean zone
    func activateCleanZoneRoute() {
        showMission(
            title: "Clean zone route available",
            body:
                "Palmer Park AQI 22 is 0.6mi north. Route avoids the I-75 corridor.")
        setProximity("n4", to: .nearby)
        if let n4 = allNodes.first(where: { $0.id == "n4" }) {
            navigateToNode(n4)
        } else {
            Task {
                let dest = MKMapItem(
                    placemark: MKPlacemark(
                        coordinate: CLLocationCoordinate2D(
                            latitude: 42.3294,
                            longitude: -83.0398)))
                dest.name = "Palmer Park Zone"
                await startNav(to: dest)
            }
        }
    }

    // Use case 6: Elderly heat alert
    func activateHeatAlert() {
        checkZoneBoundary(
            newZone: .hostile,
            leadingSignal: "Heat index 101°F")
        setProximity("n2", to: .autoReveal)
    }

    // Use case 7: Community challenge
    func activateCommunityChallenge() {
        showMission(
            title: "Active challenge nearby",
            body:
                "Walk Detroit Month · 2,840 defenders · +50 XP for joining.")
        setProximity("n11", to: .autoReveal)
    }

    // Use case 8: SVI compound surfacing
    func activateSVIView() {
        showMission(
            title: "High vulnerability tract",
            body:
                "82nd percentile SVI. Multiple compounding conditions present.")
        setProximity("n10", to: .nearby)
    }

    // Use case 9: Asthma risk route
    func activateAsthmaRoute() {
        showMission(
            title: "Asthma risk on this route",
            body:
                "2.8x hospitalization rate near interchange. Route around recommended.")
        setProximity("n12", to: .autoReveal)
    }

    // Use case 10: Green space recovery
    func activateGreenSpaceRecovery() {
        showMission(
            title: "Recovery zone nearby",
            body:
                "Riverside corridor walk score 84. HRV recovery averages +12% here.")
        setProximity("n9", to: .nearby)
    }

    func activateProximityLayer() {
        radarService.loadMockUsers(near: userLocation)
        showAnonLayer = true
        refreshProximityRadar()
    }

    func deactivateProximityLayer() {
        if activeSession != nil {
            completeSharedScan()
        }
        radarService.detectedUsers = []
        showAnonLayer = false
        showScanRequestCard = false
        selectedAnonUser = nil
        incomingRequest = nil
        showIncomingBanner = false
        showSharedScanBanner = false
        showRadiusEntryToast = false
        entryToastUser = nil
    }

    func refreshProximityRadar() {
        guard showAnonLayer else { return }
        radarService.updateDistances(
            from: userLocation
        ) { [weak self] entered, _ in
            guard let self else { return }
            for u in entered {
                self.showEntryToast(for: u)
            }
        }
        radarService.pruneExitedUsers()
    }

    func showEntryToast(for user: AnonUser) {
        entryToastUser = user
        withAnimation(
            .spring(duration: 0.3, bounce: 0.1)
        ) {
            showRadiusEntryToast = true
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.0
        ) { [weak self] in
            withAnimation {
                self?.showRadiusEntryToast = false
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.3
            ) { [weak self] in
                self?.entryToastUser = nil
            }
        }
    }

    func tapAnonUser(_ user: AnonUser) {
        guard user.isVisible,
              user.state == .visible
              || user.state == .requestSent
        else { return }
        selectedAnonUser = user
        withAnimation(
            .spring(duration: 0.4, bounce: 0.1)
        ) {
            showScanRequestCard = true
        }
        triggerAnonHaptic(.light)
    }

    func sendScanRequest(
        to user: AnonUser,
        ourZone: ZoneClassification,
        ourLens: NodeLens
    ) {
        guard let idx = radarService.detectedUsers
            .firstIndex(where: { $0.id == user.id })
        else { return }
        radarService.detectedUsers[idx].state = .requestSent
        triggerAnonHaptic(.medium)

        scanRequestService.sendRequest(
            to: user,
            ourZone: ourZone,
            ourLens: ourLens
        ) { [weak self] accepted in
            Task { @MainActor in
                guard let self else { return }
                if accepted {
                    self.beginMutualScan(with: user)
                } else {
                    if let i = self.radarService.detectedUsers
                        .firstIndex(where: { $0.id == user.id })
                    {
                        self.radarService.detectedUsers[i]
                            .state = .visible
                    }
                }
            }
        }

        withAnimation {
            showScanRequestCard = false
        }
        selectedAnonUser = nil
    }

    func beginMutualScan(with user: AnonUser) {
        guard let idx = radarService.detectedUsers
            .firstIndex(where: { $0.id == user.id })
        else { return }
        radarService.detectedUsers[idx].state = .scanning

        let session = SharedScanSession(
            id: UUID().uuidString,
            partnerUserId: user.id,
            coordinate: userLocation)
        scanRequestService.registerActiveSession(session)
        activeSession = session

        withAnimation(
            .spring(duration: 0.4, bounce: 0.1)
        ) {
            showSharedScanBanner = true
        }
        triggerAnonHaptic(.heavy)

        Task { @MainActor in
            let sharedNodes = await session.executeSharedScan(
                existingNodes: allNodes)
            for node in sharedNodes {
                if var badge = collectiveBadges[node.id] {
                    badge.defenderCount += 1
                    badge.lastScan = Date()
                    collectiveBadges[node.id] = badge
                } else {
                    collectiveBadges[node.id] =
                        CollectiveScanBadge(
                            id: node.id,
                            defenderCount: 2,
                            lastScan: Date())
                }
            }
        }
    }

    func acceptIncomingRequest() {
        guard let user = incomingRequest else { return }
        let session = scanRequestService.acceptRequest(
            from: user,
            atCoordinate: userLocation)
        activeSession = session
        withAnimation {
            showIncomingBanner = false
            incomingRequest = nil
            showSharedScanBanner = true
        }
        triggerAnonHaptic(.heavy)
        if let idx = radarService.detectedUsers
            .firstIndex(where: { $0.id == user.id })
        {
            radarService.detectedUsers[idx].state = .scanning
        }

        Task { @MainActor in
            let sharedNodes = await session.executeSharedScan(
                existingNodes: allNodes)
            for node in sharedNodes {
                if var badge = collectiveBadges[node.id] {
                    badge.defenderCount += 1
                    badge.lastScan = Date()
                    collectiveBadges[node.id] = badge
                } else {
                    collectiveBadges[node.id] =
                        CollectiveScanBadge(
                            id: node.id,
                            defenderCount: 2,
                            lastScan: Date())
                }
            }
        }
    }

    func ignoreIncomingRequest() {
        if let id = incomingRequest?.id {
            scanRequestService.ignoreRequest(from: id)
            radarService.detectedUsers.removeAll { $0.id == id }
        }
        incomingRequest = nil
        withAnimation {
            showIncomingBanner = false
        }
    }

    func completeSharedScan() {
        guard let session = activeSession else { return }
        let isHostile = allNodes.contains { n in
            distanceBetween(
                userLocation,
                n.coordinate) < 300
                && !n.type.isPositive
        }

        let earnedXP = scanRequestService.completeSession(
            session.id,
            wasHostileZone: isHostile)

        session.complete(xp: earnedXP)
        activeSession = nil

        let partnerId = session.partnerUserId
        if let idx = radarService.detectedUsers
            .firstIndex(where: { $0.id == partnerId })
        {
            radarService.detectedUsers[idx].state = .visible
        }

        withAnimation {
            showSharedScanBanner = false
        }

        lastXPEvent = earnedXP
        lastXPWasMutual = true
        lastXPWasHostile = isHostile
        withAnimation(
            .spring(duration: 0.4, bounce: 0.1)
        ) {
            showXPEvent = true
        }
        triggerAnonHaptic(.success)

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3.0
        ) { [weak self] in
            withAnimation {
                self?.showXPEvent = false
            }
        }
    }

    func simulateIncomingRequest() {
        let user = radarService.simulateUserEntering(
            near: userLocation)
        let userId = user.id

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            guard let self else { return }
            guard let idx = self.radarService.detectedUsers
                .firstIndex(where: { $0.id == userId })
            else { return }
            self.radarService.detectedUsers[idx].state =
                .entered
            self.radarService.detectedUsers[idx]
                .distanceMeters = 900
            self.showEntryToast(
                for: self.radarService.detectedUsers[idx])
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5
            ) { [weak self] in
                guard let self else { return }
                guard let i = self.radarService.detectedUsers
                    .firstIndex(where: { $0.id == userId })
                else { return }
                self.radarService.detectedUsers[i].state =
                    .requestReceived
                self.radarService.detectedUsers[i]
                    .distanceMeters = 900
                let partner =
                    self.radarService.detectedUsers[i]
                self.scanRequestService
                    .registerPendingIncoming(partner)
                self.incomingRequest = partner
                withAnimation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.1)
                ) {
                    self.showIncomingBanner = true
                }
                self.triggerAnonHaptic(.medium)
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 8.5
        ) { [weak self] in
            guard let self else { return }
            if self.incomingRequest?.id == userId {
                self.ignoreIncomingRequest()
            }
        }
    }

    private enum AnonHapticKind {
        case light, medium, heavy, success
    }

    private func triggerAnonHaptic(_ kind: AnonHapticKind) {
        switch kind {
        case .light:
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium)
                .impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy)
                .impactOccurred()
        case .success:
            UINotificationFeedbackGenerator()
                .notificationOccurred(.success)
        }
    }

    private func setProximity(
        _ id: String,
        to state: NodeProximityState
    ) {
        guard let i = allNodes.firstIndex(
            where: { $0.id == id })
        else { return }
        allNodes[i].proximityState = state
    }

    private func nodeProximity(
        _ id: String
    ) -> NodeProximityState {
        allNodes.first(
            where: { $0.id == id }
        )?.proximityState ?? .idle
    }

    private static func region(
        user: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D,
        padding: Double
    ) -> MKCoordinateRegion {
        let minLat = min(user.latitude, destination.latitude)
        let maxLat = max(user.latitude, destination.latitude)
        let minLon = min(user.longitude, destination.longitude)
        let maxLon = max(user.longitude, destination.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2)
        var dLat = (maxLat - minLat) * padding
        var dLon = (maxLon - minLon) * padding
        dLat = max(dLat, 0.012)
        dLon = max(dLon, 0.012)
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: dLat,
                longitudeDelta: dLon))
    }
}

func distanceBetween(
    _ a: CLLocationCoordinate2D,
    _ b: CLLocationCoordinate2D
) -> Double {
    let locA = CLLocation(
        latitude: a.latitude,
        longitude: a.longitude)
    let locB = CLLocation(
        latitude: b.latitude,
        longitude: b.longitude)
    return locA.distance(from: locB)
}

private func coordinate(
    from: CLLocationCoordinate2D,
    toward: CLLocationCoordinate2D,
    stepMeters: Double
) -> CLLocationCoordinate2D {
    let fromLoc = CLLocation(
        latitude: from.latitude,
        longitude: from.longitude)
    let toLoc = CLLocation(
        latitude: toward.latitude,
        longitude: toward.longitude)
    let dist = fromLoc.distance(from: toLoc)
    guard dist > stepMeters else { return toward }
    let t = stepMeters / dist
    return CLLocationCoordinate2D(
        latitude: from.latitude + (toward.latitude - from.latitude) * t,
        longitude: from.longitude + (toward.longitude - from.longitude) * t
    )
}
