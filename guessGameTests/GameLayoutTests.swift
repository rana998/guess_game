import XCTest
@testable import guessGame

final class GameLayoutTests: XCTestCase {
    func testFullSizeFromTheReferenceWidthUp() {
        XCTAssertEqual(GameLayout.fitScale(forWidth: 852, referenceWidth: 852), 1)
        XCTAssertEqual(GameLayout.fitScale(forWidth: 932, referenceWidth: 786), 1)
    }

    func testScalesDownBelowTheReferenceWidth() {
        XCTAssertEqual(GameLayout.fitScale(forWidth: 667, referenceWidth: 786), 667.0 / 786, accuracy: 0.0001)
    }
}
