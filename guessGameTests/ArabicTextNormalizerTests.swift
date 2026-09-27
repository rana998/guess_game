import XCTest
@testable import guessGame

final class ArabicTextNormalizerTests: XCTestCase {
    private let normalizer = ArabicTextNormalizer()

    func testTrimsAndCollapsesWhitespace() {
        XCTAssertEqual(normalizer.normalize("  وحيد \n  القرن  "), "وحيد القرن")
    }

    func testDropsDiacritics() {
        XCTAssertEqual(normalizer.normalize("وَحِيدُ القَرْنِ"), "وحيد القرن")
        XCTAssertEqual(normalizer.normalize("مُدَرِّسٌ"), "مدرس")
        XCTAssertEqual(normalizer.normalize("هٰذا"), "هذا")
    }

    func testDropsTatweel() {
        XCTAssertEqual(normalizer.normalize("وحيـــد"), "وحيد")
    }

    func testUnifiesAlefForms() {
        XCTAssertEqual(normalizer.normalize("أحمد إبراهيم آمن ٱلله"), "احمد ابراهيم امن الله")
    }

    func testUnifiesTaMarbutaAndAlefMaqsura() {
        XCTAssertEqual(normalizer.normalize("زرافة"), "زرافه")
        XCTAssertEqual(normalizer.normalize("مستشفى"), "مستشفي")
    }

    func testUnifiesHamzaCarriers() {
        XCTAssertEqual(normalizer.normalize("مؤمن"), "مومن")
        XCTAssertEqual(normalizer.normalize("طائرة"), "طايره")
    }

    func testDropsInvisibleMarks() {
        XCTAssertEqual(normalizer.normalize("حص\u{200C}ان\u{200F}"), "حصان")
    }

    func testSplitsPresentationForms() {
        XCTAssertEqual(normalizer.normalize("ﻻ"), "لا")
    }

    func testDropsPunctuation() {
        XCTAssertEqual(normalizer.normalize("حصان؟"), "حصان")
        XCTAssertEqual(normalizer.normalize("قطة، كلب!"), "قطه كلب")
    }

    func testLowercasesLatin() {
        XCTAssertEqual(normalizer.normalize("iPhone"), "iphone")
    }

    func testEmptyStaysEmpty() {
        XCTAssertEqual(normalizer.normalize(""), "")
        XCTAssertEqual(normalizer.normalize("  ؟ "), "")
    }
}
