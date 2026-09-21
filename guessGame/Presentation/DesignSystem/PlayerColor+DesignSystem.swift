import SwiftUI

/// How each identity color looks and is announced. The cases themselves are
/// Domain; only this mapping knows about SwiftUI.
extension PlayerColor {
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
        case .green: Strings.Swatch.green
        case .gold: Strings.Swatch.gold
        case .blue: Strings.Swatch.blue
        case .pink: Strings.Swatch.pink
        case .purple: Strings.Swatch.purple
        case .teal: Strings.Swatch.teal
        }
    }
}
