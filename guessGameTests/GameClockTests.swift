import XCTest
@testable import guessGame

final class GameClockTests: XCTestCase {
    func testReadsTheTimeOnlyWhenRefreshed() {
        let date = MutableDate(GameFixtures.startDate)
        let clock = GameClock(currentDate: { date.now })
        date.now = GameFixtures.startDate.addingTimeInterval(30)
        XCTAssertEqual(clock.now, GameFixtures.startDate)
        XCTAssertEqual(clock.refresh(), date.now)
        XCTAssertEqual(clock.now, date.now)
    }
}
