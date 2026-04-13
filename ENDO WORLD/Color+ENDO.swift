import SwiftUI

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let bgPrimary = Color(hex: "#0A0A0F")
    static let bgDark = Color(hex: "#07070D")
    static let bgSurface = Color(hex: "#1D1D21")
    static let bgElevated = Color(hex: "#252528")
    static let bgCard = Color(hex: "#141420")
    static let bgSheet = Color(hex: "#0D0D14")
    static let endoCyan = Color(hex: "#00E5FF")
    static let endoRed = Color(hex: "#FF3B3B")
    static let endoAmber = Color(hex: "#FFB800")
    static let endoGreen = Color(hex: "#34C759")
    static let endoPurple = Color(hex: "#BF5AF2")
    static let cyanCTA = Color(hex: "#042C53")
}

func zoneColor(_ score: Int) -> Color {
    score >= 66 ? .endoGreen
        : score >= 35 ? .endoAmber
        : .endoRed
}

func aqiColor(_ aqi: Int) -> Color {
    switch aqi {
    case 0 ..< 51: return .endoGreen
    case 51 ..< 101: return Color(hex: "#FFD60A")
    case 101 ..< 151: return Color(hex: "#FF9F0A")
    default: return .endoRed
    }
}

func hrColor(_ hr: Double) -> Color {
    hr > 100 ? .endoAmber
        : hr < 50 ? Color(hex: "#378ADD")
        : .endoGreen
}

func hrvColor(_ hrv: Double) -> Color {
    hrv < 20 ? .endoRed
        : hrv < 35 ? .endoAmber
        : .endoGreen
}

func pm25Color(_ pm25: Double) -> Color {
    pm25 < 12 ? .endoGreen
        : pm25 < 35.4 ? Color(hex: "#FFD60A")
        : .endoRed
}

func noiseColor(_ db: Int) -> Color {
    db > 85 ? .endoRed
        : db > 70 ? .endoAmber
        : .endoGreen
}
