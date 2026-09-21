import SwiftUI

/// The player-identity colors offered by Create Room's swatch picker. Declared
/// in reading order: the first case sits on the physical right under the app's
/// forced RTL layout, so the mockup's left-to-right order is the reverse.
///
/// Lives in Presentation because it maps to SwiftUI colors; a future Domain
/// player-color identity would reduce this to that mapping.
enum AvatarColor: CaseIterable, Hashable {
    case green, gold, blue, pink, purple, teal

    var color: Color {
        switch self {
        case .green: .brandLime
        case .gold: .avatarGold
        case .blue: .avatarBlue
        case .pink: .avatarPink
        case .purple: .avatarPurple
        case .teal: .avatarTeal
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .green: Strings.CreateRoom.swatchGreen
        case .gold: Strings.CreateRoom.swatchGold
        case .blue: Strings.CreateRoom.swatchBlue
        case .pink: Strings.CreateRoom.swatchPink
        case .purple: Strings.CreateRoom.swatchPurple
        case .teal: Strings.CreateRoom.swatchTeal
        }
    }
}
