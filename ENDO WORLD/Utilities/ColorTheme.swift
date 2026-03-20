import SwiftUI

extension Color {
    static let endoBackground   = Color(hex: "#151619")
    static let endoSurface     = Color(hex: "#1D1D21")
    static let endoSurfaceElev  = Color(hex: "#252528")
    static let endoCyan         = Color(hex: "#00E5FF")
    static let endoRed          = Color(hex: "#FF3B3B")
    static let endoAmber        = Color(hex: "#FFB800")
    static let endoGreen        = Color(hex: "#34C759")
    static let endoPurple       = Color(hex: "#BF5AF2")
    static let ouraReadiness    = Color(hex: "#5DCAA5")
    static let ouraSleep        = Color(hex: "#9F7AEA")
    static let ouraActivity     = Color(hex: "#68D391")
    static let ouraStress       = Color(hex: "#F6AD55")
    static let ouraHR           = Color(hex: "#63B3ED")
    static let tabBarBg         = Color(hex: "#1C1C20")

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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
