#if DEBUG
import Foundation

/// The round mockups' game for previews and snapshots only: the waiting-room
/// lobby's six players in round 3 of 6, with نهى describing "وحيد القرن".
extension Game {
    /// The previews' fixed clock, 47 seconds before the sample round ends.
    static let sampleNow = Date(timeIntervalSinceReferenceDate: 800_000_000)

    static func sample(phase: RoundPhase, marks: [ClueMark] = [], guesses: [Guess] = []) -> Game {
        let room = Room.sampleLobby()
        let playerIds = room.players.map(\.id)
        let hasWord = phase != .choosingWord
        let hasTimerStarted = phase != .choosingWord && phase != .wordDrawn
        var round = Round(index: 2, describerId: "lobby-0", phase: phase, marks: marks, guesses: guesses)
        round.difficulty = hasWord ? .medium : nil
        round.word = hasWord ? "وحيد القرن" : nil
        round.endsAt = hasTimerStarted ? sampleNow.addingTimeInterval(47) : nil
        round.endedAt = round.isEnded ? sampleNow : nil
        return Game(
            players: room.players,
            roundSeconds: room.roundSeconds,
            turnOrder: TurnOrder.rotation(of: playerIds, startingAt: 4),
            currentRound: round,
            scores: Dictionary(playerIds.map { playerId in (playerId, 0) }, uniquingKeysWith: { first, _ in first })
        )
    }
}
#endif
