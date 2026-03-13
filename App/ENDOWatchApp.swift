import SwiftUI

@main
struct ENDOWatchApp: App {
    @State private var viewModel = WatchZoneViewModel()

    var body: some Scene {
        WindowGroup {
            WatchMapView()
                .environment(viewModel)
        }
    }
}
