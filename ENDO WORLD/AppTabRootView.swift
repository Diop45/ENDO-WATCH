import SwiftUI

struct AppTabRootView: View {
    @Environment(AppState.self) private var appState
    @State private var tabRouter = TabRouter()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var router = tabRouter
        return TabView(selection: $router.selected) {
            MapRootView()
                .tabItem {
                    Label(
                        EndoTab.map.title,
                        systemImage: EndoTab.map.systemImage)
                }
                .tag(EndoTab.map)

            EndoStubTabView(
                title: "Today",
                subtitle:
                    "Full environmental and biometric "
                    + "detail for your walk.")
                .tabItem {
                    Label(
                        EndoTab.today.title,
                        systemImage: EndoTab.today.systemImage)
                }
                .tag(EndoTab.today)

            EndoStubTabView(
                title: "Vitals",
                subtitle:
                    "Live vitals and trends outside the map.")
                .tabItem {
                    Label(
                        EndoTab.vitals.title,
                        systemImage: EndoTab.vitals.systemImage)
                }
                .tag(EndoTab.vitals)

            EndoStubTabView(
                title: "Health",
                subtitle:
                    "Health records and goals.")
                .tabItem {
                    Label(
                        EndoTab.health.title,
                        systemImage: EndoTab.health.systemImage)
                }
                .tag(EndoTab.health)
        }
        .environment(tabRouter)
        .tint(Color.endoCyan)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                appState.biometricStream.start()
            case .background, .inactive:
                appState.biometricStream.stop()
            default:
                break
            }
        }
    }
}
