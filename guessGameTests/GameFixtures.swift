import Foundation
@testable import guessGame

/// Builders for games in any state, so each test states only what it's about.
enum GameFixtures {
    static let startDate = Date(timeIntervalSinceReferenceDate: 0)

    /// Players "لاعب0"… with ids "player-0"…, in room order; player 0 owns the room.
    static func players(count: Int) -> [Player] {
        (0..<count).map { position in
            Player(
                id: playerId(position),
                name: "لاعب\(position)",
                color: PlayerColor.allCases[position % PlayerColor.allCases.count],
                isOwner: position == 0,
                isReady: true
            )
        }
    }

    static func playerId(_ position: Int) -> String { "player-\(position)" }

    /// A game whose turn order is the room order, so player N describes round N.
    static func game(
        playerCount: Int = 4,
        roundIndex: Int = 0,
        phase: RoundPhase = .describing,
        marks: [ClueMark] = [],
        guesses: [Guess] = [],
        difficulty: Difficulty? = .medium,
        word: String? = "وحيد القرن",
        endsAt: Date? = startDate.addingTimeInterval(60),
        endedAt: Date? = nil,
        roundSeconds: Int = 60
    ) -> Game {
        let players = players(count: playerCount)
        let turnOrder = players.map(\.id)
        let round = Round(
            index: roundIndex,
            describerId: turnOrder[roundIndex],
            phase: phase,
            difficulty: difficulty,
            word: word,
            endsAt: endsAt,
            endedAt: endedAt,
            marks: marks,
            guesses: guesses
        )
        return Game(
            players: players,
            roundSeconds: roundSeconds,
            turnOrder: turnOrder,
            currentRound: round,
            scores: Dictionary(uniqueKeysWithValues: turnOrder.map { playerId in (playerId, 0) })
        )
    }
}
