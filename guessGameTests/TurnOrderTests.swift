import XCTest
@testable import guessGame

final class TurnOrderTests: XCTestCase {
    private let playerIds = ["a", "b", "c", "d"]

    func testStartsAtTheChosenPlayerThenFollowsRoomOrder() {
        XCTAssertEqual(TurnOrder.rotation(of: playerIds, startingAt: 0), ["a", "b", "c", "d"])
        XCTAssertEqual(TurnOrder.rotation(of: playerIds, startingAt: 2), ["c", "d", "a", "b"])
        XCTAssertEqual(TurnOrder.rotation(of: playerIds, startingAt: 3), ["d", "a", "b", "c"])
    }

    func testEveryPlayerAppearsExactlyOnce() {
        for startIndex in playerIds.indices {
            let rotation = TurnOrder.rotation(of: playerIds, startingAt: startIndex)
            XCTAssertEqual(rotation.count, playerIds.count)
            XCTAssertEqual(Set(rotation), Set(playerIds))
        }
    }

    func testOutOfRangeStartWraps() {
        XCTAssertEqual(TurnOrder.rotation(of: playerIds, startingAt: 5), ["b", "c", "d", "a"])
        XCTAssertEqual(TurnOrder.rotation(of: playerIds, startingAt: -1), ["d", "a", "b", "c"])
    }

    func testNoPlayersNoOrder() {
        XCTAssertEqual(TurnOrder.rotation(of: [], startingAt: 0), [])
    }
}
