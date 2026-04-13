import Foundation

/// States an anonymous user moves through relative to the one-mile radius.
enum AnonUserState {
    case outsideRadius
    case entered
    case visible
    case requestSent
    case requestReceived
    case scanning
    case sessionEnded
}
