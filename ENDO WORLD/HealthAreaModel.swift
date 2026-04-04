import Foundation
import SwiftUI

struct HealthArea: Identifiable {
    let id: String
    let label: String
    let status: String
    let progress: Double
    let color: Color
    let isEnvironmental: Bool
}

let defaultHealthAreas: [HealthArea] = [
    HealthArea(
        id: "env_exposure",
        label: "Environmental Exposure",
        status: "Moderate",
        progress: 0.55,
        color: Color(hex: "#00E5FF"),
        isEnvironmental: true
    ),
    HealthArea(
        id: "air_burden",
        label: "Air Quality Burden",
        status: "Low",
        progress: 0.82,
        color: Color(hex: "#00E5FF").opacity(0.65),
        isEnvironmental: true
    ),
    HealthArea(
        id: "neighborhood",
        label: "Neighborhood Score",
        status: "74 / 100",
        progress: 0.74,
        color: Color(hex: "#00E5FF").opacity(0.45),
        isEnvironmental: true
    ),
    HealthArea(
        id: "cardiovascular",
        label: "Cardiovascular",
        status: "Optimal",
        progress: 0.85,
        color: Color(hex: "#00E5FF"),
        isEnvironmental: false
    ),
    HealthArea(
        id: "stress",
        label: "Stress Load",
        status: "Moderate",
        progress: 0.52,
        color: Color(hex: "#FFB800"),
        isEnvironmental: false
    ),
    HealthArea(
        id: "sleep",
        label: "Sleep Quality",
        status: "Good",
        progress: 0.72,
        color: Color(hex: "#9F7AEA"),
        isEnvironmental: false
    ),
    HealthArea(
        id: "activity",
        label: "Activity",
        status: "Good",
        progress: 0.68,
        color: Color(hex: "#68D391"),
        isEnvironmental: false
    )
]
