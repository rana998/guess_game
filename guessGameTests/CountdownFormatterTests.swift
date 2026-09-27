import XCTest
@testable import guessGame

final class CountdownFormatterTests: XCTestCase {
    func testMinutesAndTwoDigitSeconds() {
        XCTAssertEqual(CountdownFormatter.text(seconds: 90), "1:30")
        XCTAssertEqual(CountdownFormatter.text(seconds: 60), "1:00")
        XCTAssertEqual(CountdownFormatter.text(seconds: 47), "0:47")
        XCTAssertEqual(CountdownFormatter.text(seconds: 5), "0:05")
    }

    func testNeverNegative() {
        XCTAssertEqual(CountdownFormatter.text(seconds: 0), "0:00")
        XCTAssertEqual(CountdownFormatter.text(seconds: -3), "0:00")
    }

    func testFullLengthBeforeDescribingThenTheTimeLeft() {
        let start = GameFixtures.startDate
        let waiting = GameFixtures.game(phase: .wordDrawn, endsAt: nil, roundSeconds: 90)
        XCTAssertEqual(CountdownFormatter.text(for: waiting, at: start), "1:30")
        let describing = GameFixtures.game(endsAt: start.addingTimeInterval(60))
        XCTAssertEqual(CountdownFormatter.text(for: describing, at: start.addingTimeInterval(13)), "0:47")
    }
}
