import XCTest
@testable import guessGame

final class WaitingRoomSessionTests: XCTestCase {
    private func room(playerCount: Int, capacity: Int) -> Room {
        Room(
            code: "1234",
            capacity: capacity,
            players: (0..<playerCount).map { playerIndex in Player(id: "\(playerIndex)", name: "لاعب\(playerIndex)", color: .green, isOwner: playerIndex == 0, isReady: true) }
        )
    }

    func testJoiningAppendsANotReadyParticipantAtTheEnd() throws {
        let session = try XCTUnwrap(WaitingRoomSession.joining(room(playerCount: 2, capacity: 4), name: "ضيف", color: .pink, playerId: "new"))
        XCTAssertEqual(session.role, .participant)
        XCTAssertEqual(session.currentPlayerId, "new")
        XCTAssertEqual(session.room.players.count, 3)
        XCTAssertEqual(session.room.players.last, Player(id: "new", name: "ضيف", color: .pink, isOwner: false, isReady: false))
        XCTAssertEqual(session.room.players.prefix(2).map(\.id), ["0", "1"])
    }

    func testJoiningAFullRoomGivesNoSession() {
        XCTAssertNil(WaitingRoomSession.joining(room(playerCount: 4, capacity: 4), name: "ضيف", color: .pink, playerId: "new"))
    }
}
