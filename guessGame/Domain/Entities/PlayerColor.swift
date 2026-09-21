/// The identity colors a player can pick in a room. Declared in reading order:
/// the first case sits on the physical right of a swatch row under the app's
/// forced RTL layout, so the mockups' left-to-right order is the reverse.
///
/// Says nothing about how a color looks — Presentation maps each case to a
/// SwiftUI color.
enum PlayerColor: CaseIterable, Hashable {
    case green, gold, blue, pink, purple, teal
}
