import SwiftUI

/// Wireframe “Demo” control: ellipsis menu with scenarios + incoming-scan demo.
struct WireframeDemoMenu: View {
    @Bindable var vm: MapViewModel

    private static let titles: [String] = [
        "Morning route · asthma",
        "Chronic condition check",
        "Care desert alert",
        "Food + disease compound",
        "Route to clean zone",
        "Heat alert · elderly",
        "Community challenge",
        "SVI vulnerability",
        "Asthma risk route",
        "Green space recovery",
    ]

    var body: some View {
        Menu {
            Section("Scenarios") {
                ForEach(Self.titles.indices, id: \.self) { index in
                    Button(Self.titles[index]) {
                        UseCasePanel.runUseCase(
                            index: index,
                            vm: vm)
                    }
                }
            }
            Button("Simulate incoming scan") {
                vm.simulateIncomingRequest()
            }
        } label: {
            ZStack {
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous)
                    .fill(Color.bgSheet.opacity(0.90))
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous)
                    .strokeBorder(
                        Color.white.opacity(0.08),
                        lineWidth: 0.5)
                Image(systemName: "ellipsis")
                    .font(.system(
                        size: 15,
                        weight: .medium))
                    .foregroundStyle(
                        Color.white.opacity(0.55))
            }
            .frame(width: 40, height: 40)
        }
        .menuStyle(.automatic)
        .accessibilityLabel("Demo menu")
    }
}

#Preview {
    @Previewable @State var vm = MapViewModel()
    WireframeDemoMenu(vm: vm)
        .padding()
        .background(Color.bgPrimary)
}
