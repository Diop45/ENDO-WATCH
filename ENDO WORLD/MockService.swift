import CoreLocation
import Foundation
import SwiftUI

enum MockService {
    static let detroit = CLLocationCoordinate2D(
        latitude: 42.3314, longitude: -83.0458
    )

    static func nodes() -> [HealthNode] {
        [
            HealthNode(
                id: "n1",
                coordinate: CLLocationCoordinate2D(latitude: 42.3344, longitude: -83.0498),
                type: .aqiHotspot,
                lenses: [.outcome],
                title: "Midtown AQI Hotspot",
                subtitle: "Industrial emissions cluster",
                score: 28,
                envMetricLabel: "AQI",
                envMetricValue: "148",
                envMetricColor: Color(hex: "#FF3B3B"),
                insightWord: "Unhealthy.",
                interpretation: "Unhealthy for sensitive groups",
                whyItMatters:
                    "Sustained exposure above AQI 100 increases asthma risk by 34% and suppresses HRV in individuals with cardiovascular conditions. This area has been elevated for 72 consecutive hours.",
                correlationNote:
                    "When you are in this zone your HRV runs 22% below your baseline on average.",
                actions: [
                    NodeAction(id: "a1", label: "Route around", isPrimary: true),
                    NodeAction(id: "a2", label: "View causes", isPrimary: false)
                ],
                relatedFactors: ["I-75 Traffic", "Steel Plant", "Low Tree Cover"],
                envMetrics: [
                    NodeMetric(label: "AQI", value: "148", color: Color(hex: "#FF3B3B")),
                    NodeMetric(label: "PM2.5", value: "44.2", color: Color(hex: "#FFB800"))
                ],
                bioMetrics: [
                    NodeMetric(label: "My HR", value: "108 bpm", color: Color(hex: "#FFB800")),
                    NodeMetric(label: "My HRV", value: "24 ms", color: Color(hex: "#FF3B3B"))
                ],
                source: "EPA AirNow",
                state: .idle
            ),
            HealthNode(
                id: "n2",
                coordinate: CLLocationCoordinate2D(latitude: 42.3294, longitude: -83.0398),
                type: .zoneCondition,
                lenses: [.outcome, .behavior],
                title: "Palmer Park Zone",
                subtitle: "Clean air · Activity zone",
                score: 91,
                envMetricLabel: "AQI",
                envMetricValue: "22",
                envMetricColor: Color(hex: "#34C759"),
                insightWord: "Clean.",
                interpretation: "Clean air. Good conditions for activity.",
                whyItMatters:
                    "Palmer Park ranks in the top 10% of Detroit green zones for air quality and walkability. Sustained activity here lowers HRV stress markers by 18% in 45 minutes.",
                correlationNote:
                    "Your HRV tends to run 14% above baseline after 30 minutes in this zone.",
                actions: [NodeAction(id: "b1", label: "Navigate here", isPrimary: true)],
                relatedFactors: ["High Tree Cover", "Low PM2.5", "Walkable"],
                envMetrics: [
                    NodeMetric(label: "AQI", value: "22", color: Color(hex: "#34C759")),
                    NodeMetric(label: "PM2.5", value: "4.1", color: Color(hex: "#34C759"))
                ],
                bioMetrics: [
                    NodeMetric(label: "My HR", value: "68 bpm", color: Color(hex: "#34C759")),
                    NodeMetric(label: "My HRV", value: "54 ms", color: Color(hex: "#34C759"))
                ],
                source: "EPA AirNow",
                state: .idle
            ),
            HealthNode(
                id: "n3",
                coordinate: CLLocationCoordinate2D(latitude: 42.3384, longitude: -83.0428),
                type: .hospital,
                lenses: [.care],
                title: "Detroit Medical Center",
                subtitle: "Level I Trauma · 0.8mi",
                score: nil,
                envMetricLabel: "Distance",
                envMetricValue: "0.8mi",
                envMetricColor: Color(hex: "#00E5FF"),
                insightWord: "Accessible.",
                interpretation: "Above average care. 18 min wait.",
                whyItMatters:
                    "Access to Level I trauma care within 1 mile reduces cardiovascular event mortality by up to 28%. This facility accepts Medicaid and offers same-day urgent appointments.",
                correlationNote:
                    "Care deserts within 2 miles increase emergency delay risk by 3.2x.",
                actions: [
                    NodeAction(id: "c1", label: "Navigate", isPrimary: true),
                    NodeAction(id: "c2", label: "Compare nearby", isPrimary: false)
                ],
                relatedFactors: ["Medicaid", "Same-day Urgent", "Spanish", "Arabic"],
                envMetrics: [
                    NodeMetric(label: "Grade", value: "B", color: Color(hex: "#00E5FF")),
                    NodeMetric(label: "Wait", value: "18 min", color: Color(hex: "#FFB800"))
                ],
                bioMetrics: [
                    NodeMetric(label: "Distance", value: "0.8mi", color: .white.opacity(0.5)),
                    NodeMetric(label: "Travel", value: "4 min", color: .white.opacity(0.5))
                ],
                source: "HRSA · CMS",
                state: .idle
            ),
            HealthNode(
                id: "n4",
                coordinate: CLLocationCoordinate2D(latitude: 42.3264, longitude: -83.0338),
                type: .diabetesCluster,
                lenses: [.outcome],
                title: "Type 2 Diabetes Cluster",
                subtitle: "6 Mile corridor · High burden",
                score: nil,
                envMetricLabel: "Prevalence",
                envMetricValue: "18.4%",
                envMetricColor: Color(hex: "#BF5AF2"),
                insightWord: "Critical.",
                interpretation: "3.1x the city average of 5.9%.",
                whyItMatters:
                    "This census tract has the highest Type 2 diabetes concentration in Detroit. Zero full-service grocery stores exist within 1.5 miles. Environmental stress compounds metabolic risk.",
                correlationNote:
                    "Residents with diabetes in this zone show 2.4x higher cardiovascular event rates than the city average.",
                actions: [
                    NodeAction(id: "d1", label: "View causes", isPrimary: true),
                    NodeAction(id: "d2", label: "Interventions", isPrimary: false)
                ],
                relatedFactors: ["Food Desert", "High AQI", "No Parks", "Low Income"],
                envMetrics: [
                    NodeMetric(label: "Prevalence", value: "18.4%", color: Color(hex: "#BF5AF2")),
                    NodeMetric(label: "City avg", value: "5.9%", color: .white.opacity(0.4))
                ],
                bioMetrics: [
                    NodeMetric(label: "Risk level", value: "High", color: Color(hex: "#FF3B3B")),
                    NodeMetric(label: "Trend", value: "Rising", color: Color(hex: "#FFB800"))
                ],
                source: "CDC PLACES · Census",
                state: .idle
            ),
            HealthNode(
                id: "n5",
                coordinate: CLLocationCoordinate2D(latitude: 42.3324, longitude: -83.0448),
                type: .communityChallenge,
                lenses: [.behavior],
                title: "Walk Detroit Month",
                subtitle: "Community challenge · Active",
                score: nil,
                envMetricLabel: "Participants",
                envMetricValue: "2,840",
                envMetricColor: Color(hex: "#00E5FF"),
                insightWord: "Active.",
                interpretation: "247 defenders scanning this zone.",
                whyItMatters:
                    "Collective walking challenges in this zone have reduced measured stress markers by 12% in participant cohorts over 30 days. Each scan contributes to block-level health intelligence.",
                correlationNote:
                    "Participants show an average HRV improvement of 8% over 30 days of challenge engagement.",
                actions: [NodeAction(id: "e1", label: "Join · +50 XP", isPrimary: true)],
                relatedFactors: ["Community", "Activity", "Clean Zone", "XP Reward"],
                envMetrics: [
                    NodeMetric(label: "Zone AQI", value: "38", color: Color(hex: "#34C759")),
                    NodeMetric(label: "Participants", value: "2,840", color: Color(hex: "#00E5FF"))
                ],
                bioMetrics: [
                    NodeMetric(label: "Avg HRV gain", value: "+8%", color: Color(hex: "#34C759")),
                    NodeMetric(label: "XP reward", value: "+50", color: Color(hex: "#00E5FF"))
                ],
                source: "ENDO Collective",
                state: .active
            )
        ]
    }

    static func challenges() -> [ENDOChallenge] {
        [
            ENDOChallenge(
                id: "c1",
                title: "Walk Detroit Month",
                isCollective: true,
                participants: 2840,
                progress: 0.62,
                xp: 50,
                lensColor: .endoCyan
            ),
            ENDOChallenge(
                id: "c2",
                title: "Scan 5 Hostile Zones",
                isCollective: false,
                participants: 1,
                progress: 0.40,
                xp: 25,
                lensColor: .endoRed
            ),
            ENDOChallenge(
                id: "c3",
                title: "Map Care Deserts",
                isCollective: true,
                participants: 412,
                progress: 0.78,
                xp: 35,
                lensColor: .endoGreen
            )
        ]
    }

    static func friends() -> [ENDOFriend] {
        [
            ENDOFriend(
                id: "f1",
                displayName: "Marcus T.",
                initials: "MT",
                coordinate: CLLocationCoordinate2D(latitude: 42.3354, longitude: -83.0428),
                zone: .supportive,
                score: 88,
                lastSeen: Date(),
                color: .endoGreen
            ),
            ENDOFriend(
                id: "f2",
                displayName: "Aisha K.",
                initials: "AK",
                coordinate: CLLocationCoordinate2D(latitude: 42.3274, longitude: -83.0388),
                zone: .hostile,
                score: 24,
                lastSeen: Date().addingTimeInterval(-120),
                color: .endoRed
            )
        ]
    }

    static func hrvValues() -> [Double] {
        [48, 50, 52, 48, 44, 40, 36, 38, 42, 46,
         50, 52, 48, 44, 40, 36, 34, 32, 30, 28,
         26, 24, 24, 28]
    }

    static func hrValues() -> [Double] {
        [68, 70, 72, 75, 74, 71, 73, 76, 78, 74,
         72, 70, 69, 71, 73, 75, 74, 72, 70, 68,
         80, 90, 100, 108]
    }

    static func spo2Values() -> [Double] {
        [97, 97, 98, 97, 96, 97, 98, 98, 97, 97,
         97, 98, 97, 96, 97, 98, 97, 97, 97, 98,
         97, 97, 98, 97]
    }

    static func aqiTrend() -> [Double] {
        [38, 40, 42, 45, 50, 55, 65, 80, 90, 100,
         110, 120, 130, 140, 148, 145, 148, 146,
         144, 148, 150, 148, 146, 148]
    }
}
