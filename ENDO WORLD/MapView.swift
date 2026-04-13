import Combine
import MapKit
import SwiftUI

struct MapView: View {
    @Bindable var vm: MapViewModel
    @Environment(AppState.self) private var appState
    @Environment(TabRouter.self) private var tabRouter

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $vm.position) {
                if vm.nav.isActive || vm.simulator.isRunning {
                    Annotation(
                        "You",
                        coordinate: vm.userLocation
                    ) {
                        Circle()
                            .fill(Color.endoCyan.opacity(0.92))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        .white.opacity(0.45),
                                        lineWidth: 0.5))
                    }
                } else {
                    UserAnnotation()
                }

                if vm.scanActive {
                    ForEach(
                        0 ..< MapViewModel.scanRippleRingCount,
                        id: \.self
                    ) { index in
                        let stride =
                            MapViewModel.scanRippleStrideMeters
                        let radius = max(
                            0,
                            vm.scanRadius - Double(index) * stride)
                        if radius > 16 {
                            let opacity =
                                0.78 - Double(index) * 0.085
                            let lineWidth =
                                index == 0
                                    ? 2.25
                                    : max(
                                        0.5,
                                        2.0 - CGFloat(index) * 0.2)
                            MapCircle(
                                center: MockService.detroit,
                                radius: radius)
                                .foregroundStyle(.clear)
                                .stroke(
                                    Color.endoCyan.opacity(opacity),
                                    style: StrokeStyle(
                                        lineWidth: lineWidth,
                                        lineCap: .round,
                                        lineJoin: .round))
                        }
                    }
                }

                if vm.healthLayerOn {
                    ForEach(vm.standaloneVisibleNodes) { node in
                        Annotation(
                            node.title,
                            coordinate: node.coordinate,
                            anchor: .bottom
                        ) {
                            ZStack {
                                NodeAnnotationView(
                                    node: node,
                                    challengePinnedIdle: vm
                                        .isLockedCommunityChallenge(
                                            node),
                                    onTap: {
                                        vm.selectNode(node)
                                    })
                                if let badge = vm.collectiveBadges[
                                    node.id],
                                   badge.isRecent,
                                   badge.defenderCount >= 2
                                {
                                    CollectiveScanBadgeView(
                                        defenderCount:
                                            badge.defenderCount,
                                        nodeColor:
                                            node.primaryLens.color)
                                        .offset(
                                            y: node.proximityState
                                                == .selected
                                                ? 48 : 32)
                                }
                            }
                        }
                    }

                    ForEach(vm.compoundNodes) { compound in
                        Annotation(
                            compound.title,
                            coordinate:
                                compound.coordinate,
                            anchor: .bottom
                        ) {
                            CompoundNodeAnnotationView(
                                compound: compound,
                                onTap: {
                                    vm.dismissNode()
                                    vm.selectedFriend = nil
                                    vm.selectedCompound = compound
                                })
                        }
                    }
                }

                if vm.friendsVisible {
                    ForEach(vm.friends) { f in
                        Annotation(
                            f.displayName,
                            coordinate: f.coordinate,
                            anchor: .bottom
                        ) {
                            FriendAnnotationView(
                                friend: f,
                                onTap: {
                                    vm.selectedFriend = f
                                })
                        }
                    }
                }

                if vm.showAnonLayer {
                    ForEach(
                        vm.radarService.visibleUsers
                    ) { user in
                        Annotation(
                            "",
                            coordinate: user.coordinate,
                            anchor: .center
                        ) {
                            ZStack {
                                AnonUserAnnotationView(
                                    user: user,
                                    onTap: {
                                        vm.tapAnonUser(user)
                                    })

                                if let badge =
                                    vm.collectiveBadges[user.id],
                                    badge.isRecent,
                                    badge.defenderCount >= 2
                                {
                                    CollectiveScanBadgeView(
                                        defenderCount:
                                            badge.defenderCount,
                                        nodeColor:
                                            user.zoneSignal == .hostile
                                                ? .endoRed
                                                : .endoCyan)
                                        .offset(
                                            y: user.dotSize / 2 + 10)
                                }
                            }
                        }
                    }
                }

                if let poly = vm.routePolyline {
                    MapPolyline(poly)
                        .stroke(
                            Color(
                                red: 0,
                                green: 0.478,
                                blue: 1.0),
                            style: StrokeStyle(
                                lineWidth: 5.5,
                                lineCap: .round,
                                lineJoin: .round))
                }

                if vm.nav.isActive,
                   let destCoord = vm.nav.destinationCoordinate
                {
                    Annotation(
                        "Destination",
                        coordinate: destCoord,
                        anchor: .center
                    ) {
                        NavigationDestinationMapMarker(
                            nav: vm.nav)
                    }
                }

                if vm.showAnonLayer {
                    MapCircle(
                        center: vm.userLocation,
                        radius: anonDetectionRadius)
                        .foregroundStyle(
                            Color.endoCyan.opacity(0.03))
                        .stroke(
                            Color.endoCyan.opacity(0.08),
                            lineWidth: 0.5)
                }
            }
            .mapStyle(endoDarkMapStyle())
            .mapControls {
                if !vm.nav.isActive {
                    MapCompass()
                    MapScaleView()
                }
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity)
            .ignoresSafeArea(.all)
            .onTapGesture { vm.tapMap() }

            WireframeMapTopChrome(vm: vm)
                .frame(maxWidth: .infinity, alignment: .top)
                .allowsHitTesting(true)
                .zIndex(20)

            if vm.showRadiusEntryToast,
               let entryUser = vm.entryToastUser
            {
                VStack {
                    Spacer().frame(height: 56)
                    RadiusEntryToast(user: entryUser)
                    Spacer()
                }
                .transition(
                    .move(edge: .top)
                        .combined(with: .opacity))
                .animation(
                    .spring(duration: 0.3, bounce: 0.1),
                    value: vm.showRadiusEntryToast)
                .zIndex(13)
                .allowsHitTesting(false)
            }

            if vm.zoneBannerVisible {
                VStack {
                    ZoneEntryBanner(
                        zone: vm.zoneBannerZone,
                        signal: vm.zoneBannerSignal,
                        navActive: false)
                        .padding(.top, 56)
                        .padding(.horizontal, 12)
                    Spacer()
                }
                .transition(
                    .move(edge: .top)
                        .combined(with: .opacity))
                .zIndex(10)
            }

            if vm.missionVisible {
                VStack {
                    Spacer().frame(height: 120)
                    MissionBanner(
                        title: vm.missionTitle,
                        missionBody: vm.missionBody,
                        onDismiss: { vm.dismissMission() })
                        .padding(.horizontal, 12)
                    Spacer()
                }
                .transition(
                    .move(edge: .top)
                        .combined(with: .opacity))
                .zIndex(9)
            }

            HStack(alignment: .top) {
                Spacer()
                    .allowsHitTesting(false)
                VStack(alignment: .trailing, spacing: 10) {
                    Spacer().frame(height: 56)
                    MapCtrlBtn(
                        icon: "location.fill"
                    ) { vm.recentre() }
                    MapCtrlBtn(
                        icon: "dot.radiowaves.left.and.right",
                        active: vm.healthLayerOn,
                        accent: .endoCyan
                    ) { vm.toggleHealth() }
                    .accessibilityLabel("Environmental scan")
                    MapCtrlBtn(
                        icon: "scope",
                        active: vm.missionVisible,
                        accent: .endoAmber
                    ) {
                        if vm.missionVisible {
                            vm.dismissMission()
                        } else {
                            vm.showMission(
                                title: "Air quality mission",
                                body: "AQI 148 detected nearby. Walk to Palmer Park for clean air.")
                        }
                    }
                    MapCtrlBtn(
                        icon: "link.circle.fill",
                        active: vm.showAnonLayer,
                        accent: Color(hex: "#888780"),
                        badge: vm.radarService.visibleUsers
                            .isEmpty
                            ? nil
                            : "\(vm.radarService.visibleUsers.count)"
                    ) {
                        if vm.showAnonLayer {
                            vm.deactivateProximityLayer()
                        } else {
                            vm.activateProximityLayer()
                        }
                    }
                    .accessibilityLabel("Nearby ENDO users")
                    WireframeDemoMenu(vm: vm)
                    Spacer()
                }
                .padding(.trailing, 12)
            }

            if vm.revealCardVisible,
               !vm.nav.isActive,
               let node = vm.revealNode,
               !vm.isLockedCommunityChallenge(node)
            {
                VStack {
                    Spacer()
                    ProximityRevealCard(
                        node: node,
                        isMatchingStripCondition:
                            !node.type.isPositive
                            && appState.zone == .hostile
                            && appState.aqi > 100,
                        onExpand: {
                            vm.selectNode(node)
                        },
                        onDismiss: {
                            withAnimation {
                                vm.revealCardVisible = false
                                vm.revealNode = nil
                            }
                        })
                        .padding(.horizontal, 14)
                        .padding(.bottom, 120)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .animation(
                    .spring(duration: 0.4,
                              bounce: 0.1),
                    value: vm.revealCardVisible)
                .zIndex(7)
            }

            if let inviteId = vm.challengeInviteNodeId,
               let inviteNode = vm.allNodes.first(where: {
                   $0.id == inviteId
               })
            {
                VStack {
                    Spacer()
                    ChallengeInviteCard(
                        node: inviteNode,
                        onJoin: { vm.acceptChallengeInvite() },
                        onDecline: { vm.declineChallengeInvite() })
                        .padding(.horizontal, 14)
                        .padding(.bottom, 100)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .zIndex(85)
            }

            if vm.sheetState == .preview,
               !vm.nav.isActive,
               let node = vm.selectedNode
            {
                VStack {
                    Spacer()
                    NodePreviewCard(
                        node: node,
                        userHR: Int(
                            appState.hr),
                        userHRV: Int(appState.hrv),
                        onExpand: {
                            let label =
                                node.actions.first?.label ?? ""
                            let isNavAction =
                                label.contains("Route")
                                || label.contains("Navigate")
                                || label.contains("Find")
                            if isNavAction {
                                vm.navigateToNode(node)
                                vm.dismissNode()
                            } else {
                                vm.sheetState = .expanded
                            }
                        },
                        onDismiss: {
                            vm.dismissNode()
                        },
                        dismissDragThreshold: node.type
                            == .communityChallenge
                            ? 36 : 60,
                        onExitChallenge: node.type
                            == .communityChallenge
                            ? { vm.dismissNode() }
                            : nil)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 24)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .animation(
                    .spring(duration: 0.4,
                              bounce: 0.15),
                    value: vm.sheetState)
                .zIndex(8)
            }

            if let f = vm.selectedFriend, !vm.nav.isActive {
                VStack {
                    Spacer()
                    FriendPreviewCard(
                        friend: f,
                        onNavigate: {
                            vm.navigateToFriend(f)
                            vm.selectedFriend = nil
                        },
                        onDismiss: {
                            vm.selectedFriend = nil
                        })
                        .padding(.horizontal, 14)
                        .padding(.bottom, 24)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .zIndex(8)
            }

            if vm.selectedNode == nil
                && vm.selectedFriend == nil
                && vm.selectedCompound == nil
                && !vm.nav.isActive
                && !vm.showScanRequestCard
                && !vm.revealCardVisible
                && vm.challengeInviteNodeId == nil
            {
                VStack {
                    Spacer()
                    ZoneBottomBar(
                        onNavigateOut: {
                            if let cleanNode = vm.allNodes
                                .filter({ ($0.score ?? 0) >= 66 })
                                .sorted(by: {
                                    distanceBetween(
                                        vm.userLocation,
                                        $0.coordinate)
                                        < distanceBetween(
                                            vm.userLocation,
                                            $1.coordinate)
                                }).first
                            {
                                vm.navigateToNode(cleanNode)
                            }
                        })
                        .padding(.horizontal, 12)
                        .padding(.bottom, 88)
                }
                .zIndex(6)
            }

            VStack {
                Spacer()
                AmbientHealthStrip(
                    zone: appState.zone,
                    aqi: appState.aqi,
                    heatF: appState.heatF,
                    hrDisplay: appState.biometricStream
                        .hrDisplayString,
                    hrvDisplay: appState.biometricStream
                        .hrvDisplayString,
                    hrNumeric: appState.biometricStream
                        .hasReadAccess
                        ? appState.biometricStream.currentHR
                        : nil,
                    hrvNumeric: appState.biometricStream
                        .hasReadAccess
                        ? appState.biometricStream.currentHRV
                        : nil,
                    nearbyHostileCount:
                        vm.nearbyHostileNodeCount,
                    onTap: {
                        tabRouter.openToday()
                    })
                    .padding(.horizontal, 12)
                    .padding(.bottom, 88)
            }
            .zIndex(7)

            if vm.nav.isActive {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    NavigationFindMyOverlay(vm: vm)
                        .padding(.horizontal, 0)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.1),
                    value: vm.nav.isActive)
                .zIndex(9)
            }

            if vm.showScanRequestCard,
               let user = vm.selectedAnonUser
            {
                VStack {
                    Spacer()
                    ScanRequestCard(
                        user: user,
                        onSendRequest: {
                            let lens =
                                vm.activeLens == .all
                                ? NodeLens.outcome
                                : vm.activeLens
                            vm.sendScanRequest(
                                to: user,
                                ourZone: ZoneClassification.from(
                                    appState.zoneScore),
                                ourLens: lens)
                        },
                        onDismiss: {
                            withAnimation {
                                vm.showScanRequestCard = false
                                vm.selectedAnonUser = nil
                            }
                        })
                        .padding(.horizontal, 14)
                        .padding(.bottom, 24)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.1),
                    value: vm.showScanRequestCard)
                .zIndex(11)
            }

            if vm.showIncomingBanner,
               let incoming = vm.incomingRequest
            {
                VStack {
                    Spacer().frame(height: 120)
                    IncomingRequestBanner(
                        user: incoming,
                        onAccept: {
                            vm.acceptIncomingRequest()
                        },
                        onIgnore: {
                            vm.ignoreIncomingRequest()
                        })
                        .padding(.horizontal, 12)
                    Spacer()
                }
                .transition(
                    .move(edge: .top)
                        .combined(with: .opacity))
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.1),
                    value: vm.showIncomingBanner)
                .zIndex(10)
            }

            if vm.showSharedScanBanner,
               let session = vm.activeSession
            {
                VStack {
                    Spacer().frame(height: 120)
                    SharedScanBanner(
                        session: session,
                        onComplete: {
                            vm.completeSharedScan()
                        })
                        .padding(.horizontal, 12)
                    Spacer()
                }
                .transition(
                    .move(edge: .top)
                        .combined(with: .opacity))
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.1),
                    value: vm.showSharedScanBanner)
                .zIndex(10)
            }

            if vm.showXPEvent {
                VStack {
                    Spacer()
                    XPEventCard(
                        xp: vm.lastXPEvent,
                        isMutual: vm.lastXPWasMutual,
                        isHostile: vm.lastXPWasHostile)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 90)
                }
                .transition(
                    .move(edge: .bottom)
                        .combined(with: .opacity))
                .animation(
                    .spring(
                        duration: 0.4,
                        bounce: 0.1),
                    value: vm.showXPEvent)
                .zIndex(12)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .onAppear {
            vm.loadNodes()
            vm.activateProximityLayer()
        }
        .onChange(of: vm.activeLens) { _, _ in
            vm.ensureMapHealthData()
        }
        .onReceive(
            Timer.publish(
                every: 0.8,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in
            if vm.simulator.isRunning {
                vm.advanceLocationSimulation()
            }
            vm.refreshProximityRadar()
        }
        .animation(
            .easeInOut(duration: 0.25),
            value: vm.healthLayerOn)
        .sheet(
            isPresented: Binding(
                get: { vm.sheetState == .expanded },
                set: { expanded in
                    if !expanded {
                        vm.sheetState =
                            vm.selectedNode != nil
                                ? .preview : .hidden
                    }
                })) {
                    NodeDetailSheet(
                        node: vm.selectedNode,
                        onExitChallenge: {
                            vm.dismissNode()
                        })
                        .presentationDetents(
                            [.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.clear)
                        .presentationBackgroundInteraction(.disabled)
                }
        .sheet(
            isPresented: Binding(
                get: {
                    vm.selectedCompound != nil
                },
                set: { presented in
                    if !presented {
                        vm.selectedCompound = nil
                    }
                })) {
                    if let compound = vm.selectedCompound {
                        CompoundNodeSheet(
                            compound: compound)
                            .presentationDetents(
                                [.medium, .large])
                            .presentationDragIndicator(.visible)
                            .presentationBackground(.clear)
                            .presentationBackgroundInteraction(.disabled)
                    }
                }
    }

    private func endoDarkMapStyle() -> MapStyle {
        if #available(iOS 18.0, *) {
            return .standard(
                elevation: .automatic,
                emphasis: .muted,
                pointsOfInterest: .excludingAll)
        }
        return .standard
    }
}

/// Map pin at the navigation destination (friend initials or zone icon).
private struct NavigationDestinationMapMarker: View {
    let nav: NavigationModel

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 40, height: 40)
                .shadow(
                    color: .black.opacity(0.35),
                    radius: 4,
                    y: 2)
            if let friend = nav.destinationFriend {
                Text(friend.initials)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(friend.color)
            } else if let node = nav.destinationNode {
                Image(systemName: node.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(node.primaryLens.color)
            }
        }
        .overlay(
            Circle()
                .strokeBorder(
                    Color.black.opacity(0.08),
                    lineWidth: 0.5))
    }
}

#Preview("Map · default") {
    @Previewable @State var vm = MapViewModel()
    MapView(vm: vm)
        .environment(AppState())
        .environment(TabRouter())
        .preferredColorScheme(.dark)
}

#Preview("Map · health layer") {
    @Previewable @State var vm = MapViewModel()
    MapView(vm: vm)
        .environment(AppState())
        .environment(TabRouter())
        .preferredColorScheme(.dark)
        .onAppear {
            vm.healthLayerOn = true
            if vm.allNodes.isEmpty {
                vm.allNodes = MockService.nodes()
            }
            vm.friends = MockService.friends()
        }
}

#Preview("Map · preview card") {
    @Previewable @State var vm = MapViewModel()
    MapView(vm: vm)
        .environment(AppState())
        .environment(TabRouter())
        .preferredColorScheme(.dark)
        .onAppear {
            vm.healthLayerOn = true
            vm.allNodes = MockService.nodes()
            if let first = vm.allNodes.first {
                vm.selectNode(first)
            }
        }
}

#Preview("Map · expanded sheet") {
    @Previewable @State var vm = MapViewModel()
    MapView(vm: vm)
        .environment(AppState())
        .environment(TabRouter())
        .preferredColorScheme(.dark)
        .onAppear {
            vm.healthLayerOn = true
            vm.allNodes = MockService.nodes()
            if let first = vm.allNodes.first {
                vm.selectNode(first)
                vm.sheetState = .expanded
            }
        }
}
