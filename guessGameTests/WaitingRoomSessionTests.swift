import XCTest
@testable import guessGame

final class WaitingRoomSessionTests: XCTestCase {
    private func room(players: Int, capacity: Int) -> Room {
        Room(
            code: "1234",
            capacity: capacity,
            players: (0..<players).map { Player(id: "\($0)", name: "لاعب\($0)", color: .green, isOwner: $0 == 0, isReady: true) }
        )
    }

    func testJoiningAppendsANotReadyParticipantAtTheEnd() throws {
        let session = try XCTUnwrap(WaitingRoomSession.joining(room(players: 2, capacity: 4), name: "ضيف", color: .pink, playerId: "new"))
        XCTAssertEqual(session.role, .participant)
        XCTAssertEqual(session.currentPlayerId, "new")
        XCTAssertEqual(session.room.players.count, 3)
        XCTAssertEqual(session.room.players.last, Player(id: "new", name: "ضيف", color: .pink, isOwner: false, isReady: false))
        XCTAssertEqual(session.room.players.prefix(2).map(\.id), ["0", "1"])
    }

    func testJoiningAFullRoomGivesNoSession() {
        XCTAssertNil(WaitingRoomSession.joining(room(players: 4, capacity: 4), name: "ضيف", color: .pink, playerId: "new"))
    }
}
