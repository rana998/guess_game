import XCTest
@testable import guessGame

final class PlayerColorTests: XCTestCase {
    func testCasesAreInSwatchReadingOrder() {
        XCTAssertEqual(PlayerColor.allCases, [.green, .gold, .blue, .pink, .purple, .teal])
    }

    func testEveryColorHasAUniqueAccessibilityLabel() {
        let labels = PlayerColor.allCases.map(\.accessibilityLabel)
        XCTAssertFalse(labels.contains(""))
        XCTAssertEqual(Set(labels).count, PlayerColor.allCases.count)
    }
}
