import XCTest
@testable import guessGame

final class ScoringRulesTests: XCTestCase {
    func testHarderWordsScoreMore() {
        XCTAssertEqual(ScoringRules.guesserPoints(for: .easy), 1)
        XCTAssertEqual(ScoringRules.guesserPoints(for: .medium), 2)
        XCTAssertEqual(ScoringRules.guesserPoints(for: .hard), 3)
    }

    func testDescriberGetsOnePoint() {
        XCTAssertEqual(ScoringRules.describerPoints, 1)
    }
}
