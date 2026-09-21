import SwiftUI

/// Symbolic accessors for the color tokens defined in DESIGN_SYSTEM.md.
/// Each wraps an Assets.xcassets color set with an Any/Dark appearance pair.
extension Color {
    static let paper = Color("Paper")
    static let brandLime = Color("BrandLime")
    static let brandRed = Color("BrandRed")
    static let brandYellow = Color("BrandYellow")

    /// Darker green used only for the "Set the idea" info card's border, where
    /// `brandLime` is too light to read as an outline. Lifts slightly in Dark Mode.
    static let brandLimeDeep = Color("BrandLimeDeep")

    /// Pale card fills paired with `brandRed` / `brandLime`-family borders.
    /// They darken in Dark Mode so `inkText` keeps its contrast on them.
    static let tintRed = Color("TintRed")
    static let tintLime = Color("TintLime")

    /// Player-identity swatch colors (Create Room's color picker). They keep the
    /// same value in Dark Mode: like `brandYellow`, they identify a player and
    /// still clear 3:1 against the dark Paper background.
    static let avatarTeal = Color("AvatarTeal")
    static let avatarPurple = Color("AvatarPurple")
    static let avatarPink = Color("AvatarPink")
    static let avatarBlue = Color("AvatarBlue")
    static let avatarGold = Color("AvatarGold")

    /// Disabled ("locked") code boxes on Join Room's room-full state: a muted
    /// surface, outline and digit that read as unavailable, not as an error.
    /// They lift/darken in Dark Mode to stay distinguishable from the dark Paper.
    static let lockedFill = Color("LockedFill")
    static let lockedStroke = Color("LockedStroke")
    static let lockedText = Color("LockedText")

    /// Comic-outline stroke color (buttons, wordmark, badges). Stays dark-ink-colored
    /// in both appearances — it mimics printed ink around a shape, not body text.
    static let inkStroke = Color("InkStroke")

    /// Body/label text color. Inverts to a warm off-white in Dark Mode for legibility,
    /// unlike `inkStroke` which must stay dark in both appearances.
    static let inkText = Color("InkText")
}
