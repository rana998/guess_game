import XCTest
@testable import guessGame

final class AvatarBadgeTests: XCTestCase {
    private let placeholder = "نهى"

    func testInitialTrimsWhitespace() {
        XCTAssertEqual(AvatarBadge.initial(from: " نهى ", placeholder: placeholder), "ن")
    }

    func testEmptyNameFallsBackToPlaceholderInitial() {
        XCTAssertEqual(AvatarBadge.initial(from: "", placeholder: placeholder), "ن")
        XCTAssertEqual(AvatarBadge.initial(from: "   ", placeholder: placeholder), "ن")
    }

    func testInitialKeepsDiacriticAttachedToItsLetter() {
        XCTAssertEqual(AvatarBadge.initial(from: "نَهى", placeholder: placeholder), "نَ")
    }

    func testLatinInitialIsUppercased() {
        XCTAssertEqual(AvatarBadge.initial(from: "sara", placeholder: placeholder), "S")
    }
}
