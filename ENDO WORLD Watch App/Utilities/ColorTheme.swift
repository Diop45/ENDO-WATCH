import SwiftUI

extension Color {

    // MARK: - Dashboard palette (ENDO World watch)

    static let background  = Color(hex: "#F2F2F0")
    static let surface     = Color(hex: "#E8E8E6")
    static let labelGray   = Color(hex: "#8A8A8A")
    static let nearBlack   = Color(hex: "#1A1A1A")
    static let chartreuse  = Color(hex: "#C8FF00")
    static let iridescentA = Color(hex: "#A8D8FF")
    static let iridescentB = Color(hex: "#D4A8FF")

    // Zone colors
    static let supportiveZone = Color(hex: "#34C759")
    static let moderateZone   = Color(hex: "#FF9F0A")
    static let hostileZone    = Color(hex: "#FF3B3B")

    // MARK: - Map / HUD palette (spec)

    static let endoBackground = Color(hex: "#0A0A0F")
    static let endoSurface    = Color(hex: "#1A1A2E")
    static let endoCyan       = Color(hex: "#00E5FF")
    static let endoRed        = Color(hex: "#FF3B3B")
    static let endoAmber      = Color(hex: "#FFB800")
    static let endoGreen      = Color(hex: "#34C759")
    static let endoHostile    = Color(hex: "#FF3B3B")
    static let endoModerate   = Color(hex: "#FFB800")
    static let endoSupportive = Color(hex: "#00E5FF")
    static let endoSecondary  = Color(hex: "#1A1A2E")

    // MARK: - Onboarding palette (light)

    static let onboardBg    = Color(hex: "#E8F4F8")
    static let onboardCard  = Color.white
    static let onboardNavy  = Color(hex: "#0D1B2A")
    static let onboardSlate = Color(hex: "#4A6274")
    static let onboardCyan  = Color(hex: "#00B4D8")
    static let onboardMuted = Color(hex: "#C5D8E0")

    // MARK: - Hex initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Iridescent gradient shorthand

extension LinearGradient {
    static let iridescent = LinearGradient(
        colors: [.iridescentA, .iridescentB],
        startPoint: .leading,
        endPoint: .trailing
    )
}
