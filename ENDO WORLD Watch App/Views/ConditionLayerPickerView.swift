import SwiftUI

// MARK: - ConditionLayerPickerView

struct ConditionLayerPickerView: View {
    @Bindable var layerManager: ConditionLayerManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(SignalCategory.allCases, id: \.rawValue) { category in
                    Button(action: {
                        layerManager.toggleLayer(category)
                    }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(categoryColor(category))
                                .frame(width: 5, height: 5)
                            Text(categoryShortName(category))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(
                                    layerManager.isVisible(category)
                                    ? .white
                                    : .white.opacity(0.4)
                                )
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            layerManager.isVisible(category)
                            ? categoryColor(category).opacity(0.2)
                            : .white.opacity(0.05)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(
                                layerManager.isVisible(category)
                                ? categoryColor(category).opacity(0.5)
                                : .clear,
                                lineWidth: 0.5
                            )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: layerManager.isVisible(category))
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
    }

    private func categoryShortName(_ cat: SignalCategory) -> String {
        switch cat {
        case .biometric:      return "Bio"
        case .environmental:  return "Env"
        case .movement:       return "Move"
        case .urbanStress:    return "Urban"
        case .healthPatterns: return "Patterns"
        }
    }
}
