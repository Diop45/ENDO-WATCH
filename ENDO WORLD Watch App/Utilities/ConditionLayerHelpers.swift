import SwiftUI

// MARK: - Category colors (layer colors, distinct from zone colors)

func categoryColor(_ category: SignalCategory) -> Color {
    switch category {
    case .biometric:      return Color(hex: "#FF3B3B")
    case .environmental:  return Color(hex: "#00E5FF")
    case .movement:       return Color(hex: "#34C759")
    case .urbanStress:    return Color(hex: "#FFB800")
    case .healthPatterns: return Color(hex: "#BF5AF2")
    }
}

func categoryRadius(_ category: SignalCategory) -> Double {
    switch category {
    case .biometric:      return 55
    case .environmental:  return 80
    case .movement:       return 65
    case .urbanStress:    return 70
    case .healthPatterns: return 50
    }
}

func categoryIcon(_ category: SignalCategory) -> String {
    switch category {
    case .biometric:      return "heart.fill"
    case .environmental:  return "wind"
    case .movement:       return "figure.walk"
    case .urbanStress:    return "building.2.fill"
    case .healthPatterns: return "waveform.path.ecg"
    }
}
