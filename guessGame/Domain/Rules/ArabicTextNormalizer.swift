import Foundation

/// Folds the ways the same Arabic word gets typed on a phone into one form:
/// diacritics and tatweel dropped, hamza/alef, ta marbuta and alef maqsura
/// variants unified, punctuation and extra spaces removed.
struct ArabicTextNormalizer {
    /// Harakat, superscript alef, Quranic marks, tatweel and invisible direction/joining marks.
    private static let removedScalarRanges: [ClosedRange<UInt32>] = [
        0x064B...0x065F, 0x0670...0x0670, 0x06D6...0x06ED, 0x0640...0x0640,
        0x200B...0x200F, 0x061C...0x061C, 0xFEFF...0xFEFF,
    ]

    private static let letterReplacements: [Unicode.Scalar: Unicode.Scalar] = [
        "أ": "ا", "إ": "ا", "آ": "ا", "ٱ": "ا",
        "ة": "ه", "ى": "ي", "ؤ": "و", "ئ": "ي",
    ]

    private static let separators = CharacterSet.punctuationCharacters.union(.symbols)

    func normalize(_ text: String) -> String {
        // Compatibility mapping splits presentation forms such as "ﻻ" into their letters.
        let foldedText = text.precomposedStringWithCompatibilityMapping.lowercased()
        var normalizedScalars = String.UnicodeScalarView()
        for scalar in foldedText.unicodeScalars {
            if Self.removedScalarRanges.contains(where: { range in range.contains(scalar.value) }) {
                continue
            } else if Self.separators.contains(scalar) {
                normalizedScalars.append(" ")
            } else {
                normalizedScalars.append(Self.letterReplacements[scalar] ?? scalar)
            }
        }
        return String(normalizedScalars)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { word in !word.isEmpty }
            .joined(separator: " ")
    }
}
