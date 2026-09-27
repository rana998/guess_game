import XCTest
@testable import guessGame

final class RandomIndexPickerTests: XCTestCase {
    func testEmptyRangeGivesNoIndex() {
        XCTAssertNil(RandomIndexPicker.system.index(below: 0))
    }

    func testOutOfRangePicksWrapIntoTheRange() {
        XCTAssertEqual(RandomIndexPicker { _ in 7 }.index(below: 5), 2)
        XCTAssertEqual(RandomIndexPicker { _ in -1 }.index(below: 5), 4)
    }

    func testSystemPickStaysInRange() {
        for _ in 0..<200 {
            let index = RandomIndexPicker.system.index(below: 6)
            XCTAssertNotNil(index)
            XCTAssertTrue((0..<6).contains(index ?? -1))
        }
    }
}
