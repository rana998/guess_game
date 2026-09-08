import SwiftUI

/// Symbolic accessors for the color tokens defined in DESIGN_SYSTEM.md.
/// Each wraps an Assets.xcassets color set with an Any/Dark appearance pair.
extension Color {
    static let paper = Color("Paper")
    static let brandLime = Color("BrandLime")
    static let brandRed = Color("BrandRed")
    static let brandYellow = Color("BrandYellow")

    /// Comic-outline stroke color (buttons, wordmark, badges). Stays dark-ink-colored
    /// in both appearances — it mimics printed ink around a shape, not body text.
    static let inkStroke = Color("InkStroke")

    /// Body/label text color. Inverts to a warm off-white in Dark Mode for legibility,
    /// unlike `inkStroke` which must stay dark in both appearances.
    static let inkText = Color("InkText")
}
