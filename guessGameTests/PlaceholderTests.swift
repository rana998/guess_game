import XCTest

/// Keeps the guessGameTests target buildable while no Domain-layer logic exists yet.
/// Remove once the first real use case (and its tests) ships.
final class PlaceholderTests: XCTestCase {
    func testPlaceholder() {
        XCTAssertTrue(true)
    }
}
