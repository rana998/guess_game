import XCTest
@testable import guessGame

final class WaitingRoomViewTests: XCTestCase {
    func testFitScaleIsExactlyOneFromTheGridWidthUp() {
        XCTAssertEqual(WaitingRoomView.fitScale(forWidth: 852), 1)
        XCTAssertEqual(WaitingRoomView.fitScale(forWidth: 778), 1)
    }

    func testFitScaleShrinksNarrowerScreensToFitTheGrid() {
        // Grid 746 + 16 on each side = 778.
        XCTAssertEqual(WaitingRoomView.fitScale(forWidth: 667), 667 / 778, accuracy: 0.0001)
        XCTAssertLessThan(WaitingRoomView.fitScale(forWidth: 600), 1)
    }
}
