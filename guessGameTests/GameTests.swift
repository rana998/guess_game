import XCTest
@testable import guessGame

final class GameTests: XCTestCase {
    func testGuessersAreEveryoneButTheDescriberInRoomOrder() {
        let game = GameFixtures.game(playerCount: 5, roundIndex: 2)
        XCTAssertEqual(game.describer?.id, "player-2")
        XCTAssertEqual(game.guessers.map(\.id), ["player-0", "player-1", "player-3", "player-4"])
    }

    func testRoundCountIsOneRoundPerPlayer() {
        XCTAssertEqual(GameFixtures.game(playerCount: 3).roundCount, 3)
        XCTAssertEqual(GameFixtures.game(playerCount: 6).roundCount, 6)
    }

    func testIsLastRound() {
        XCTAssertFalse(GameFixtures.game(playerCount: 4, roundIndex: 2).isLastRound)
        XCTAssertTrue(GameFixtures.game(playerCount: 4, roundIndex: 3).isLastRound)
    }

    func testRoundsUntilTurnCountsFutureTurnsOnly() {
        let game = GameFixtures.game(playerCount: 6, roundIndex: 2)
        XCTAssertEqual(game.roundsUntilTurn(of: "player-3"), 1)
        XCTAssertEqual(game.roundsUntilTurn(of: "player-4"), 2)
        XCTAssertEqual(game.roundsUntilTurn(of: "player-5"), 3)
        XCTAssertNil(game.roundsUntilTurn(of: "player-2"), "describing now")
        XCTAssertNil(game.roundsUntilTurn(of: "player-1"), "already described")
        XCTAssertNil(game.roundsUntilTurn(of: "stranger"))
    }

    func testFindsPlayersById() {
        let game = GameFixtures.game(playerCount: 3)
        XCTAssertEqual(game.player(id: "player-1")?.name, "لاعب1")
        XCTAssertNil(game.player(id: "stranger"))
    }
}
