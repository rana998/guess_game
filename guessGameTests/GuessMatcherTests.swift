import XCTest
@testable import guessGame

final class GuessMatcherTests: XCTestCase {
    private let matcher = GuessMatcher()

    func testExactWordMatches() {
        XCTAssertTrue(matcher.matches("وحيد القرن", word: "وحيد القرن"))
    }

    func testDiacriticsDoNotMatter() {
        XCTAssertTrue(matcher.matches("وَحِيد القَرْن", word: "وحيد القرن"))
    }

    func testSpacesDoNotMatter() {
        XCTAssertTrue(matcher.matches("وحيدالقرن", word: "وحيد القرن"))
        XCTAssertTrue(matcher.matches("  وحيد   القرن ", word: "وحيد القرن"))
    }

    func testSpellingVariantsMatch() {
        XCTAssertTrue(matcher.matches("زرافه", word: "زرافة"))
        XCTAssertTrue(matcher.matches("مستشفي", word: "مستشفى"))
        XCTAssertTrue(matcher.matches("احمد", word: "أحمد"))
    }

    func testTheDefiniteArticleIsOptional() {
        XCTAssertTrue(matcher.matches("الزرافة", word: "زرافة"))
        XCTAssertTrue(matcher.matches("زرافه", word: "الزرافة"))
    }

    func testDifferentWordsDoNotMatch() {
        XCTAssertFalse(matcher.matches("حصان", word: "حصان البحر"))
        XCTAssertFalse(matcher.matches("زرافة", word: "وحيد القرن"))
    }

    func testShortWordsKeepTheirLeadingLetters() {
        // "الم" isn't an article on a three-letter word.
        XCTAssertFalse(matcher.matches("م", word: "الم"))
    }

    func testBlankNeverMatches() {
        XCTAssertFalse(matcher.matches("   ", word: "قطة"))
        XCTAssertFalse(matcher.matches("قطة", word: ""))
        XCTAssertFalse(matcher.matches("", word: ""))
    }
}
