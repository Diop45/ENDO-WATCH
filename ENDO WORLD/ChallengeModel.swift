import Foundation
import SwiftUI

struct ENDOChallenge: Identifiable {
    let id: String
    var title: String
    var isCollective: Bool
    var participants: Int
    var progress: Double
    var xp: Int
    var lensColor: Color
}
