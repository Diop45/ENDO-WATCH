import SwiftUI
import UIKit

struct ContentView: View {
    @State private var appState = AppState()
    @State private var connectivity = WatchConnectivityService()
    @State private var locationService = LocationService()

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
            VitalsView()
                .tabItem {
                    Label("Vitals", systemImage: "waveform.path.ecg")
                }
            MapTabView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            MyHealthView()
                .tabItem {
                    Label("My Health", systemImage: "chart.bar.fill")
                }
        }
        .tint(Color.endoCyan)
        .preferredColorScheme(.dark)
        .environment(appState)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 32/255, alpha: 1)
            appearance.shadowColor = UIColor.white.withAlphaComponent(0.07)
            appearance.shadowImage = UIImage()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            connectivity.appState = appState
            locationService.appState = appState
        }
    }
}
