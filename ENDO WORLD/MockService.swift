import CoreLocation
import Foundation
import SwiftUI

struct MockService {

    static let detroit = CLLocationCoordinate2D(
        latitude: 42.3314, longitude: -83.0458)

    static func nodes() -> [HealthNode] {
        [
            HealthNode(
                id: "n1",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3344, longitude: -83.0498),
                type: .aqiHotspot,
                lenses: [.outcome],
                title: "Midtown AQI Hotspot",
                subtitle: "I-75 industrial corridor",
                score: 28,
                envMetricLabel: "AQI",
                envMetricValue: "148",
                envMetricColor: .endoRed,
                insightWord: "Unhealthy.",
                interpretation:
                    "Unhealthy for sensitive groups",
                whyItMatters:
                    "Sustained AQI above 100 raises asthma risk by 34% and suppresses HRV. Elevated for 72 consecutive hours.",
                correlationNote:
                    "Your HRV runs 22% below baseline when you are in this zone.",
                actions: [
                    NodeAction(
                        id: "a1",
                        label: "Route around",
                        isPrimary: true),
                    NodeAction(
                        id: "a2",
                        label: "View causes",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "I-75 Traffic",
                    "Steel Plant",
                    "Low Tree Cover",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "AQI",
                        value: "148",
                        color: .endoRed),
                    NodeMetric(
                        label: "PM2.5",
                        value: "44.2",
                        color: .endoAmber),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "My HR",
                        value: "108 bpm",
                        color: .endoAmber),
                    NodeMetric(
                        label: "My HRV",
                        value: "24 ms",
                        color: .endoRed),
                ],
                trendHistory: [
                    55, 60, 58, 70, 80, 95, 110, 130, 148,
                ],
                historyLabel: "AQI · 6 months",
                source: "EPA AirNow",
                proximityState: .idle),

            HealthNode(
                id: "n2",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3264, longitude: -83.0418),
                type: .heatIsland,
                lenses: [.outcome],
                title: "Woodbridge Heat Zone",
                subtitle: "Urban heat island peak",
                score: 22,
                envMetricLabel: "Heat index",
                envMetricValue: "101°F",
                envMetricColor: .endoRed,
                insightWord: "Dangerous.",
                interpretation:
                    "Heat emergency threshold exceeded",
                whyItMatters:
                    "Heat index above 103°F triggers heat emergency conditions. Cardiovascular stress peaks. Medication sensitivity elevated in elderly populations.",
                correlationNote:
                    "Heart rate elevates 12-18 bpm on average under sustained heat exposure above 95°F.",
                actions: [
                    NodeAction(
                        id: "b1",
                        label: "Find cooling center",
                        isPrimary: true),
                    NodeAction(
                        id: "b2",
                        label: "Navigate to shade",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "Pavement density",
                    "No tree canopy",
                    "Industrial heat",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Heat index",
                        value: "101°F",
                        color: .endoRed),
                    NodeMetric(
                        label: "Surface temp",
                        value: "+14°F avg",
                        color: .endoAmber),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "My HR",
                        value: "94 bpm",
                        color: .endoAmber),
                    NodeMetric(
                        label: "Risk",
                        value: "Elevated",
                        color: .endoAmber),
                ],
                trendHistory: [88, 90, 92, 95, 97, 99, 101],
                historyLabel: "Heat index · 7 days",
                source: "NOAA NWS",
                proximityState: .idle),

            HealthNode(
                id: "n3",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3374, longitude: -83.0458),
                type: .noiseExposure,
                lenses: [.outcome],
                title: "Jefferson Ave Noise",
                subtitle: "Highway interchange zone",
                score: 38,
                envMetricLabel: "Noise",
                envMetricValue: "82 dB",
                envMetricColor: .endoAmber,
                insightWord: "Loud.",
                interpretation:
                    "Sustained above WHO 70dB limit",
                whyItMatters:
                    "Sustained noise above 70dB raises cortisol, suppresses HRV, and disrupts sleep quality. Hypertension risk increases 34% with long-term exposure.",
                correlationNote:
                    "Your HRV typically runs 14% below baseline on routes through this corridor.",
                actions: [
                    NodeAction(
                        id: "c1",
                        label: "Route around",
                        isPrimary: true),
                    NodeAction(
                        id: "c2",
                        label: "View quiet zones",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "I-75 Interchange",
                    "Commercial traffic",
                    "No sound barrier",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Noise",
                        value: "82 dB",
                        color: .endoAmber),
                    NodeMetric(
                        label: "Time avg",
                        value: "76 dB",
                        color: .endoAmber),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "My HRV",
                        value: "38 ms",
                        color: .endoAmber),
                    NodeMetric(
                        label: "Cortisol",
                        value: "Elevated",
                        color: .endoAmber),
                ],
                trendHistory: [72, 74, 76, 78, 78, 80, 82],
                historyLabel: "Noise dB · 7 days",
                source: "US DOT Noise Map",
                proximityState: .idle),

            HealthNode(
                id: "n4",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3294, longitude: -83.0398),
                type: .zoneCondition,
                lenses: [.outcome, .behavior],
                title: "Palmer Park Zone",
                subtitle: "Clean air corridor",
                score: 91,
                envMetricLabel: "AQI",
                envMetricValue: "22",
                envMetricColor: .endoGreen,
                insightWord: "Clean.",
                interpretation:
                    "Clean air. Good conditions.",
                whyItMatters:
                    "Palmer Park ranks top 10% for air quality and walkability in Detroit. 30 minutes here lowers stress markers by 18%.",
                correlationNote:
                    "HRV runs 14% above baseline after 30 minutes in this zone.",
                actions: [
                    NodeAction(
                        id: "d1",
                        label: "Navigate here",
                        isPrimary: true),
                    NodeAction(
                        id: "d2",
                        label: "Start scan",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "High tree cover",
                    "Low PM2.5",
                    "Walkable",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "AQI",
                        value: "22",
                        color: .endoGreen),
                    NodeMetric(
                        label: "PM2.5",
                        value: "4.1",
                        color: .endoGreen),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "My HR",
                        value: "68 bpm",
                        color: .endoGreen),
                    NodeMetric(
                        label: "My HRV",
                        value: "54 ms",
                        color: .endoGreen),
                ],
                trendHistory: [28, 25, 22, 24, 20, 18, 22],
                historyLabel: "AQI · 6 months",
                source: "EPA AirNow",
                proximityState: .idle),

            HealthNode(
                id: "n5",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3384, longitude: -83.0428),
                type: .hospital,
                lenses: [.care],
                title: "Detroit Medical Center",
                subtitle: "Level I Trauma · 0.8mi",
                score: nil,
                envMetricLabel: "Distance",
                envMetricValue: "0.8mi",
                envMetricColor: .endoCyan,
                insightWord: "Accessible.",
                interpretation:
                    "Above average care. 18 min wait.",
                whyItMatters:
                    "Access to Level I trauma within 1 mile reduces mortality by up to 28%. Accepts Medicaid.",
                correlationNote:
                    "Care deserts increase emergency delay risk by 3.2x.",
                actions: [
                    NodeAction(
                        id: "e1",
                        label: "Navigate",
                        isPrimary: true),
                    NodeAction(
                        id: "e2",
                        label: "Compare nearby",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "Medicaid",
                    "Same-day urgent",
                    "Spanish", "Arabic",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Grade",
                        value: "B",
                        color: .endoCyan),
                    NodeMetric(
                        label: "Wait",
                        value: "18 min",
                        color: .endoAmber),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "Distance",
                        value: "0.8mi",
                        color: .white.opacity(0.5)),
                    NodeMetric(
                        label: "Travel",
                        value: "4 min",
                        color: .white.opacity(0.5)),
                ],
                trendHistory: [],
                historyLabel: "",
                source: "HRSA · CMS",
                proximityState: .idle),

            HealthNode(
                id: "n6",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3244, longitude: -83.0528),
                type: .careDesert,
                lenses: [.care],
                title: "East Side Care Desert",
                subtitle: "Nearest care 3.8mi",
                score: 12,
                envMetricLabel: "Distance",
                envMetricValue: "3.8mi",
                envMetricColor: .endoRed,
                insightWord: "Desert.",
                interpretation:
                    "No primary care within 2 miles",
                whyItMatters:
                    "This area has no primary care within 2 miles and no pediatric specialist within 4 miles. Emergency delay risk is 3.2x the city average.",
                correlationNote:
                    "Residents in care deserts delay treatment an average of 4.2 additional days per health event.",
                actions: [
                    NodeAction(
                        id: "f1",
                        label: "Find nearest care",
                        isPrimary: true),
                    NodeAction(
                        id: "f2",
                        label: "View resources",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "No public transit",
                    "Low income",
                    "No urgent care",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Nearest care",
                        value: "3.8mi",
                        color: .endoRed),
                    NodeMetric(
                        label: "City avg",
                        value: "0.9mi",
                        color: .white.opacity(0.4)),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "Delay risk",
                        value: "3.2x",
                        color: .endoRed),
                    NodeMetric(
                        label: "Coverage",
                        value: "Low",
                        color: .endoAmber),
                ],
                trendHistory: [0.9, 1.2, 1.8, 2.4, 3.1, 3.5, 3.8],
                historyLabel: "Distance trend · 3 years",
                source: "HRSA",
                proximityState: .idle),

            HealthNode(
                id: "n7",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3214, longitude: -83.0368),
                type: .diabetesCluster,
                lenses: [.outcome],
                title: "Type 2 Diabetes Cluster",
                subtitle: "6 Mile corridor",
                score: nil,
                envMetricLabel: "Prevalence",
                envMetricValue: "18.4%",
                envMetricColor: .endoPurple,
                insightWord: "Critical.",
                interpretation:
                    "3.1x the city average of 5.9%.",
                whyItMatters:
                    "Highest Type 2 concentration in Detroit. Zero full-service grocery stores within 1.5 miles. Environmental stress compounds metabolic risk.",
                correlationNote:
                    "Residents with diabetes here show 2.4x higher cardiovascular event rates than the city average.",
                actions: [
                    NodeAction(
                        id: "g1",
                        label: "View causes",
                        isPrimary: true),
                    NodeAction(
                        id: "g2",
                        label: "Find food access",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "Food desert",
                    "High AQI",
                    "No parks",
                    "Low income",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Prevalence",
                        value: "18.4%",
                        color: .endoPurple),
                    NodeMetric(
                        label: "City avg",
                        value: "5.9%",
                        color: .white.opacity(0.4)),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "Risk level",
                        value: "High",
                        color: .endoRed),
                    NodeMetric(
                        label: "Trend",
                        value: "Rising",
                        color: .endoAmber),
                ],
                trendHistory: [12, 13, 14, 15, 16, 17, 18.4],
                historyLabel: "Prevalence · 3 years",
                source: "CDC PLACES",
                proximityState: .idle),

            HealthNode(
                id: "n8",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3224, longitude: -83.0363),
                type: .foodDesert,
                lenses: [.care],
                title: "Food Desert · 6 Mile",
                subtitle: "No grocery within 1.5mi",
                score: 8,
                envMetricLabel: "Grocery distance",
                envMetricValue: "1.5mi",
                envMetricColor: .endoRed,
                insightWord: "Sparse.",
                interpretation:
                    "No full-service grocery within 1.5 miles",
                whyItMatters:
                    "Food deserts compound metabolic disease. This block has both a food desert designation and a diabetes prevalence of 18.4%. Structurally linked.",
                correlationNote:
                    "Food access within 0.5 miles is associated with 22% lower diabetes prevalence in comparable urban tracts.",
                actions: [
                    NodeAction(
                        id: "h1",
                        label: "Find food access",
                        isPrimary: true),
                    NodeAction(
                        id: "h2",
                        label: "View resources",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "No transit to grocery",
                    "Farmers market Sat",
                    "SNAP accepted nearby",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Nearest grocery",
                        value: "1.5mi",
                        color: .endoRed),
                    NodeMetric(
                        label: "Food points",
                        value: "0 within 0.5mi",
                        color: .endoRed),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "DM2 link",
                        value: "18.4%",
                        color: .endoPurple),
                    NodeMetric(
                        label: "Risk",
                        value: "Compounded",
                        color: .endoRed),
                ],
                trendHistory: [0.6, 0.8, 0.9, 1.1, 1.2, 1.4, 1.5],
                historyLabel: "Distance · 3 years",
                source: "USDA Food Atlas",
                proximityState: .idle),

            HealthNode(
                id: "n9",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3354, longitude: -83.0318),
                type: .greenSpace,
                lenses: [.behavior],
                title: "Riverside Green Corridor",
                subtitle: "Walk score 84 · high canopy",
                score: 88,
                envMetricLabel: "Walk score",
                envMetricValue: "84",
                envMetricColor: .endoGreen,
                insightWord: "Restorative.",
                interpretation:
                    "Top 15% walkability in Detroit",
                whyItMatters:
                    "Green space exposure reduces cortisol by 16% and HRV-derived stress markers by 21% after 20 minutes. This corridor is a measurable health resource.",
                correlationNote:
                    "Users who walk this corridor show HRV recovery averaging 12% above their hostile-zone baseline.",
                actions: [
                    NodeAction(
                        id: "i1",
                        label: "Navigate here",
                        isPrimary: true),
                    NodeAction(
                        id: "i2",
                        label: "Join challenge",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "High tree cover",
                    "River access",
                    "Low noise",
                    "Low AQI",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Walk score",
                        value: "84",
                        color: .endoGreen),
                    NodeMetric(
                        label: "Green cover",
                        value: "34%",
                        color: .endoGreen),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "HRV benefit",
                        value: "+12%",
                        color: .endoGreen),
                    NodeMetric(
                        label: "Cortisol",
                        value: "-16%",
                        color: .endoGreen),
                ],
                trendHistory: [80, 81, 82, 82, 83, 84, 84],
                historyLabel: "Walk score · 6 months",
                source: "Walk Score · EPA EnviroAtlas",
                proximityState: .idle),

            HealthNode(
                id: "n10",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3274, longitude: -83.0478),
                type: .socialVulnerability,
                lenses: [.outcome],
                title: "High Vulnerability Tract",
                subtitle: "SVI 82nd percentile",
                score: 18,
                envMetricLabel: "SVI",
                envMetricValue: "82nd pctile",
                envMetricColor: .endoPurple,
                insightWord: "Vulnerable.",
                interpretation:
                    "Top quartile nationally",
                whyItMatters:
                    "This census tract ranks in the highest national quartile for social vulnerability. Low income, high uninsured rate, and limited transit access compound every environmental health burden.",
                correlationNote:
                    "High SVI tracts show 2.8x higher rates of delayed care-seeking compared to low SVI tracts at identical disease prevalence.",
                actions: [
                    NodeAction(
                        id: "j1",
                        label: "View full profile",
                        isPrimary: true),
                    NodeAction(
                        id: "j2",
                        label: "Find resources",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "28% below poverty",
                    "34% uninsured",
                    "Limited transit",
                    "Language barriers",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "SVI percentile",
                        value: "82nd",
                        color: .endoPurple),
                    NodeMetric(
                        label: "Theme",
                        value: "Socioeconomic",
                        color: .endoPurple),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "Care delay",
                        value: "2.8x",
                        color: .endoRed),
                    NodeMetric(
                        label: "Uninsured",
                        value: "34%",
                        color: .endoAmber),
                ],
                trendHistory: [
                    0.65, 0.68, 0.70, 0.73, 0.76, 0.79, 0.82,
                ],
                historyLabel: "SVI score · 7 years",
                source: "CDC SVI · Census ACS",
                proximityState: .idle),

            HealthNode(
                id: "n11",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3324, longitude: -83.0448),
                type: .communityChallenge,
                lenses: [.behavior],
                title: "Walk Detroit Month",
                subtitle: "2,840 participants",
                score: nil,
                envMetricLabel: "Participants",
                envMetricValue: "2,840",
                envMetricColor: .endoCyan,
                insightWord: "Active.",
                interpretation:
                    "247 defenders scanning this zone.",
                whyItMatters:
                    "Collective walking reduced stress markers by 12% in participant cohorts over 30 days.",
                correlationNote:
                    "Participants show HRV improvement of 8% over 30 days.",
                actions: [
                    NodeAction(
                        id: "k1",
                        label: "Join · +50 XP",
                        isPrimary: true),
                    NodeAction(
                        id: "k2",
                        label: "View leaderboard",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "Community",
                    "Activity",
                    "Clean zone",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Zone AQI",
                        value: "38",
                        color: .endoGreen),
                    NodeMetric(
                        label: "Participants",
                        value: "2,840",
                        color: .endoCyan),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "Avg HRV gain",
                        value: "+8%",
                        color: .endoGreen),
                    NodeMetric(
                        label: "XP reward",
                        value: "+50",
                        color: .endoCyan),
                ],
                trendHistory: [800, 1200, 1800, 2400, 2840],
                historyLabel: "Participation · 5 weeks",
                source: "ENDO Collective",
                proximityState: .idle),

            HealthNode(
                id: "n12",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3304, longitude: -83.0508),
                type: .asthmaRisk,
                lenses: [.outcome],
                title: "Asthma Risk Zone",
                subtitle: "Highway interchange · 2.8x city",
                score: nil,
                envMetricLabel: "Hosp rate",
                envMetricValue: "2.8x city",
                envMetricColor: .endoRed,
                insightWord: "Elevated.",
                interpretation:
                    "Asthma hospitalizations 2.8x average",
                whyItMatters:
                    "Highway interchange produces sustained particulate exposure. Asthma hospitalizations peak in summer months. SpO2 readings trend 1.2% lower on average.",
                correlationNote:
                    "Respiratory rate elevates 2-3 breaths per minute under sustained PM2.5 above 35.",
                actions: [
                    NodeAction(
                        id: "l1",
                        label: "Route around",
                        isPrimary: true),
                    NodeAction(
                        id: "l2",
                        label: "View causes",
                        isPrimary: false),
                ],
                relatedFactors: [
                    "I-75 interchange",
                    "Diesel emissions",
                    "No green buffer",
                ],
                envMetrics: [
                    NodeMetric(
                        label: "Hosp rate",
                        value: "2.8x",
                        color: .endoRed),
                    NodeMetric(
                        label: "PM2.5",
                        value: "38.1",
                        color: .endoAmber),
                ],
                bioMetrics: [
                    NodeMetric(
                        label: "My SpO2",
                        value: "96%",
                        color: .endoAmber),
                    NodeMetric(
                        label: "My RR",
                        value: "16/min",
                        color: .white.opacity(0.5)),
                ],
                trendHistory: [1.8, 2.0, 2.1, 2.3, 2.5, 2.6, 2.8],
                historyLabel: "Hosp rate · 6 months",
                source: "CDC PLACES",
                proximityState: .idle),
        ]
    }

    static func friends() -> [ENDOFriend] {
        [
            ENDOFriend(
                id: "f1",
                displayName: "Marcus T.",
                initials: "MT",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3354,
                    longitude: -83.0428),
                zone: .supportive,
                score: 88,
                lastSeen: Date(),
                color: .endoGreen),
            ENDOFriend(
                id: "f2",
                displayName: "Aisha K.",
                initials: "AK",
                coordinate: CLLocationCoordinate2D(
                    latitude: 42.3274,
                    longitude: -83.0388),
                zone: .hostile,
                score: 24,
                lastSeen: Date()
                    .addingTimeInterval(-120),
                color: .endoRed),
        ]
    }

    static func aqiTrend() -> [Double] {
        [
            38, 40, 42, 45, 50, 55, 65, 80, 90, 100,
            110, 120, 130, 140, 148, 145, 148, 146,
            144, 148, 150, 148, 146, 148,
        ]
    }

    static func hrvValues() -> [Double] {
        [
            48, 50, 52, 48, 44, 40, 36, 38, 42, 46,
            50, 52, 48, 44, 40, 36, 34, 32, 30, 28,
            26, 24, 24, 28,
        ]
    }
}
