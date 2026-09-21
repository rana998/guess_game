import XCTest
@testable import guessGame

final class EnterNameViewTests: XCTestCase {
    func testFitScaleIsExactlyOneOnIPhone16LandscapeWidths() {
        XCTAssertEqual(EnterNameView.fitScale(forWidth: 852), 1)
        XCTAssertEqual(EnterNameView.fitScale(forWidth: 734), 1)
    }

    func testFitScaleShrinksNarrowerScreensToFitTheContent() {
        // Content 736 + 50 left bias + 16 right margin = 802.
        XCTAssertEqual(EnterNameView.fitScale(forWidth: 667), 667 / 802, accuracy: 0.0001)
        XCTAssertLessThan(EnterNameView.fitScale(forWidth: 600), 1)
    }
}
