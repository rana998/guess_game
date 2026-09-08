import SwiftUI

/// Symbolic accessors for the typography scale defined in DESIGN_SYSTEM.md.
/// Font family is Almarai throughout (bundled via Resources/Fonts, registered
/// in project.yml's UIAppFonts). Each token scales with Dynamic Type via the
/// nearest matching text style while preserving the spec's base point size.
extension Font {
    static let displayLogo = Font.custom("Almarai-ExtraBold", size: 78, relativeTo: .largeTitle)
    static let displayCTA = Font.custom("Almarai-ExtraBold", size: 30, relativeTo: .title)
    static let titleScreen = Font.custom("Almarai-ExtraBold", size: 20, relativeTo: .title2)
    static let titleCard = Font.custom("Almarai-ExtraBold", size: 16, relativeTo: .title3)
    static let labelSection = Font.custom("Almarai-ExtraBold", size: 14, relativeTo: .headline)
    static let labelChip = Font.custom("Almarai-ExtraBold", size: 12.5, relativeTo: .caption)
    static let bodyMeta = Font.custom("Almarai-Light", size: 11.5, relativeTo: .caption2)
    static let bodyRegular = Font.custom("Almarai-Regular", size: 12, relativeTo: .footnote)

    /// Room code & timer only, per DESIGN_SYSTEM.md — system monospaced, not Almarai.
    static let numericMono = Font.system(.body, design: .monospaced).weight(.bold)
}
