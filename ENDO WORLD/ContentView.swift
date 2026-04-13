import Combine
import SwiftUI

struct ContentView: View {
    var body: some View {
        AppTabRootView()
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}

// Root map shell lives in this file so it always compiles with `ContentView`
// (avoids “Cannot find MapRootView in scope” if a separate file is excluded).
struct MapRootView: View {
    @Environment(AppState.self) private var appState
    @State private var mapVM = MapViewModel()

    var body: some View {
        @Bindable var vm = mapVM
        ZStack {
            appState.atmosphericBackground
                .ignoresSafeArea()
                .animation(
                    .easeInOut(duration: 2.0),
                    value: appState.zone)

            MapView(vm: vm)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity)
                .ignoresSafeArea()

            if appState.showMapIntro {
                MapIntroExplainerView()
                    .transition(.opacity)
                    .zIndex(200)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            mapVM.loadNodes()
            mapVM.bootstrapZone(appState.zone)
        }
        .task {
            await appState.startAppleHealthDataIntegration()
        }
        .onReceive(
            Timer.publish(every: 0.6, on: .main, in: .common)
                .autoconnect()
        ) { _ in
            mapVM.tickSimulatedWalkTowardTarget()
        }
        .onReceive(
            Timer.publish(every: 90, on: .main, in: .common)
                .autoconnect()
        ) { _ in
            Task {
                await appState.refreshAppleHealthData()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("Map root") {
    AppTabRootView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
