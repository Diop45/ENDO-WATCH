import SwiftUI

struct AmbientHealthStrip: View {
    let zone: ZoneClassification
    let aqi: Int
    let heatF: Int
    let hrDisplay: String
    let hrvDisplay: String
    let hrNumeric: Int?
    let hrvNumeric: Double?
    let nearbyHostileCount: Int
    var onTap: (() -> Void)? = nil

    private var envIsAffectingBody: Bool {
        aqi > 100
            || zone == .hostile
            || heatF >= 95
    }

    private var hrColor: Color {
        if let hr = hrNumeric, envIsAffectingBody {
            return zone.color
        }
        guard let hr = hrNumeric else {
            return .white.opacity(0.35)
        }
        return zoneAwareHRColor(hr, zone: zone)
    }

    private var hrvColor: Color {
        if let hrv = hrvNumeric, envIsAffectingBody {
            return zone.color.opacity(0.80)
        }
        guard let hrv = hrvNumeric else {
            return .white.opacity(0.35)
        }
        return zoneAwareHRVColor(hrv, zone: zone)
    }

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) {
                    stripContent
                }
                .buttonStyle(.plain)
            } else {
                stripContent
            }
        }
    }

    private var stripContent: some View {
        HStack(spacing: 0) {
            stripCell(
                label: "ZONE",
                value: zoneScoreFromZone,
                color: zone.color)

            stripDivider

            stripCell(
                label: "AQI",
                value: "\(aqi)",
                color: aqiStripColor(aqi))

            stripDivider

            stripCell(
                label: "HR",
                value: hrDisplay,
                color: hrColor,
                unit: hrNumeric != nil ? "bpm" : nil)

            stripDivider

            stripCell(
                label: "HRV",
                value: hrvDisplay,
                color: hrvColor,
                unit: hrvNumeric != nil ? "ms" : nil)

            if nearbyHostileCount > 0 {
                stripDivider
                nearbyIndicator
            }
        }
        .padding(.vertical, 10)
        .background(Color.bgSheet.opacity(0.96))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous))
        .overlay(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous)
                .strokeBorder(
                    zone == .hostile
                        ? Color.endoRed.opacity(0.35)
                        : Color.white.opacity(0.08),
                    lineWidth: zone == .hostile
                        ? 1.0 : 0.5))
        .overlay {
            if envIsAffectingBody {
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous)
                    .strokeBorder(
                        zone.color.opacity(0.20),
                        lineWidth: 1.0)
            }
        }
        .animation(
            .easeInOut(duration: 2.0),
            value: zone)
        .animation(
            .easeInOut(duration: 2.0),
            value: aqi)
    }

    private func stripCell(
        label: String,
        value: String,
        color: Color,
        unit: String? = nil
    ) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(
                    size: 8, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.30))
                .kerning(0.8)
                .textCase(.uppercase)
            HStack(
                alignment: .firstTextBaseline,
                spacing: 2
            ) {
                Text(value)
                    .font(.system(
                        size: 16, weight: .bold))
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .contentTransition(
                        .numericText())
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: value)
                if let unit {
                    Text(unit)
                        .font(.system(size: 8))
                        .foregroundStyle(
                            color.opacity(0.55))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var stripDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.07))
            .frame(width: 0.5, height: 28)
    }

    private var nearbyIndicator: some View {
        VStack(spacing: 3) {
            Text("NEAR")
                .font(.system(
                    size: 8, weight: .medium))
                .foregroundStyle(
                    .white.opacity(0.30))
                .kerning(0.8)
                .textCase(.uppercase)
            HStack(spacing: 3) {
                Circle()
                    .fill(Color.endoRed)
                    .frame(width: 5, height: 5)
                Text("\(nearbyHostileCount)")
                    .font(.system(
                        size: 16, weight: .bold))
                    .foregroundStyle(
                        Color.endoRed)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var zoneScoreFromZone: String {
        switch zone {
        case .supportive: "Good"
        case .moderate: "Fair"
        case .hostile: "Poor"
        }
    }
}

private func aqiStripColor(
    _ aqi: Int
) -> Color {
    switch aqi {
    case ..<51: return Color.endoGreen
    case ..<101: return Color(hex: "#FFD700")
    case ..<151: return Color.endoAmber
    default: return Color.endoRed
    }
}

private func standardHRColor(
    _ hr: Int
) -> Color {
    switch hr {
    case ..<60: return Color(hex: "#378ADD")
    case ..<100: return Color.endoGreen
    case ..<120: return Color.endoAmber
    default: return Color.endoRed
    }
}

private func standardHRVColor(
    _ hrv: Double
) -> Color {
    switch hrv {
    case 50...: return Color.endoGreen
    case 30 ..< 50: return Color.endoAmber
    default: return Color.endoRed
    }
}

/// HR coloring nudged by current zone so the same bpm reads
/// stricter in hostile air and calmer in supportive zones.
private func zoneAwareHRColor(
    _ hr: Int,
    zone: ZoneClassification
) -> Color {
    let shift: Int
    switch zone {
    case .supportive: shift = -8
    case .moderate: shift = 0
    case .hostile: shift = 10
    }
    let adjusted = min(220, max(35, hr + shift))
    return standardHRColor(adjusted)
}

/// HRV coloring adjusted for zone stress (effective recovery bar).
private func zoneAwareHRVColor(
    _ hrv: Double,
    zone: ZoneClassification
) -> Color {
    let adjusted: Double
    switch zone {
    case .supportive:
        adjusted = hrv + 4
    case .moderate:
        adjusted = hrv
    case .hostile:
        adjusted = hrv - 10
    }
    return standardHRVColor(max(0, adjusted))
}
