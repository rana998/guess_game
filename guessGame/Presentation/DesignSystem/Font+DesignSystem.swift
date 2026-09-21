import SwiftUI

/// Symbolic accessors for the typography scale defined in DESIGN_SYSTEM.md.
/// Font family is Almarai throughout (bundled via Resources/Fonts, registered
/// in project.yml's UIAppFonts). Each token scales with Dynamic Type via the
/// nearest matching text style while preserving the spec's base point size.
extension Font {
    static let displayLogo = Font.custom("Almarai-ExtraBold", size: 78, relativeTo: .largeTitle)
    // Bold, not ExtraBold: the Home mockup's CTA labels measure as Bold 30
    // (ink width 284px vs 299px for ExtraBold at the same size).
    static let displayCTA = Font.custom("Almarai-Bold", size: 30, relativeTo: .title)
    static let ctaTertiary = Font.custom("Almarai-Bold", size: 20, relativeTo: .headline)
    static let titleScreen = Font.custom("Almarai-ExtraBold", size: 20, relativeTo: .title2)
    static let titleCard = Font.custom("Almarai-ExtraBold", size: 16, relativeTo: .title3)
    static let labelSection = Font.custom("Almarai-ExtraBold", size: 14, relativeTo: .headline)
    static let labelChip = Font.custom("Almarai-ExtraBold", size: 12.5, relativeTo: .caption)
    static let bodyMeta = Font.custom("Almarai-Light", size: 12, relativeTo: .caption2)
    static let bodyRegular = Font.custom("Almarai-Regular", size: 12, relativeTo: .footnote)
    // The How to Play cards' descriptions measure as Regular 11, not 12
    // (ink fit error 0.011 vs 0.74), so they can't reuse `bodyRegular`.
    static let bodySmall = Font.custom("Almarai-Regular", size: 11, relativeTo: .caption2)
    // Create Room's sizes, each fitted against the mockup's ink (fit error
    // ≤0.004 for the chosen size/weight, ≥0.1 for its neighbours).
    static let inputText = Font.custom("Almarai-ExtraBold", size: 22, relativeTo: .title3)
    static let labelGroup = Font.custom("Almarai-ExtraBold", size: 15, relativeTo: .headline)
    static let pillValue = Font.custom("Almarai-ExtraBold", size: 24, relativeTo: .title2)
    static let bodyMetaSmall = Font.custom("Almarai-Light", size: 11, relativeTo: .caption2)
    // ExtraBold, unlike Home's Bold `displayCTA`: this mockup's label fits
    // ExtraBold 30 (error 0.001 vs 0.50 for Bold).
    static let displayCTAHeavy = Font.custom("Almarai-ExtraBold", size: 30, relativeTo: .title)
    // Join Room's sizes, fitted the same way (≤0.004 vs ≥0.05 for the neighbours).
    static let codeDigit = Font.custom("Almarai-ExtraBold", size: 32, relativeTo: .largeTitle)
    static let labelPrompt = Font.custom("Almarai-ExtraBold", size: 17, relativeTo: .headline)
    static let messageBanner = Font.custom("Almarai-ExtraBold", size: 12, relativeTo: .caption)
    static let bodyStrong = Font.custom("Almarai-Bold", size: 12, relativeTo: .caption)
    // The room-full badge's "6/6" fits SF Mono Heavy, not Almarai (error 0.001
    // vs 0.33) — the "SF Mono Heavy" DESIGN_SYSTEM.md's Numeric/Mono row names.
    static let badgeMono = Font.system(size: 18, weight: .heavy, design: .monospaced)

    /// Room code & timer only, per DESIGN_SYSTEM.md — system monospaced, not Almarai.
    static let numericMono = Font.system(.body, design: .monospaced).weight(.bold)
}
