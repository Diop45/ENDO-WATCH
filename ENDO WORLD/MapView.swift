import MapKit
import SwiftUI

struct MapView: View {
    @Environment(AppState.self) private var appState
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: MockService.detroit,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
    )
    @State private var selectedLens: NodeLens = .all
    @State private var selectedNode: HealthNode?
    @State private var nodes: [HealthNode] = MockService.nodes()
    @State private var friends: [ENDOFriend] = MockService.friends()

    private var filteredNodes: [HealthNode] {
        switch selectedLens {
        case .all: return nodes
        case .behavior, .care, .outcome:
            return nodes.filter { $0.lenses.contains(selectedLens) || $0.primaryLens == selectedLens }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $camera) {
                ForEach(filteredNodes) { node in
                    Annotation(node.title, coordinate: node.coordinate) {
                        Button {
                            selectedNode = node
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(node.envMetricColor.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: node.type.icon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(node.envMetricColor)
                            }
                        }
                        .buttonStyle(.plain)
                        .contentShape(Circle())
                    }
                }
                ForEach(friends) { friend in
                    Annotation(friend.displayName, coordinate: friend.coordinate) {
                        Text(friend.initials)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(friend.color.opacity(0.85))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                }
            }
            .mapStyle(.standard)

            VStack(alignment: .leading, spacing: 8) {
                Text("Map")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                LensFilterRow(selected: $selectedLens)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let peek = appState.peekNode {
                VStack {
                    Spacer()
                    HStack {
                        Text("Nearby · \(peek.title)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button("View") {
                            selectedNode = peek
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.endoCyan)
                        .contentShape(Rectangle())
                    }
                    .padding(12)
                    .background(Color.bgCard.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .sheet(item: $selectedNode) { node in
            NodeDetailSheet(node: node) {
                selectedNode = nil
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            if appState.peekNode == nil, let hostile = nodes.first(where: { $0.score != nil && ($0.score ?? 100) < 40 }) {
                appState.peekNode = hostile
            }
        }
    }
}

private struct LensFilterRow: View {
    @Binding var selected: NodeLens

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NodeLens.allCases, id: \.self) { lens in
                    Button {
                        selected = lens
                    } label: {
                        Text(lens.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(selected == lens ? Color.cyanCTA : .white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selected == lens ? Color.endoCyan : Color.bgCard)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())
                }
            }
        }
    }
}
