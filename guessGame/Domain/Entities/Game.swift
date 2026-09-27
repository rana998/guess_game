/// A game in progress: who plays, the describing order, the round being played
/// and the running scores (handoff `roomState` + `roundState`).
struct Game: Hashable {
    /// The room's players when the game started, in room order.
    let players: [Player]
    let roundSeconds: Int
    /// Player ids in describing order; everyone describes exactly once.
    let turnOrder: [String]
    var currentRound: Round
    var scores: [String: Int]
    /// Every word drawn so far, so none repeats within the game.
    var usedWords: Set<String> = []
    var isFinished = false

    var roundCount: Int { turnOrder.count }

    var isLastRound: Bool { currentRound.index == roundCount - 1 }

    var describer: Player? { player(id: currentRound.describerId) }

    /// Everyone but this round's describer, in room order.
    var guessers: [Player] { players.filter { player in player.id != currentRound.describerId } }

    func player(id: String) -> Player? { players.first { player in player.id == id } }

    /// How many rounds from now the player describes; nil once their turn is
    /// current or past, or for someone not in the game.
    func roundsUntilTurn(of playerId: String) -> Int? {
        guard let turnIndex = turnOrder.firstIndex(of: playerId) else { return nil }
        let roundsAway = turnIndex - currentRound.index
        return roundsAway > 0 ? roundsAway : nil
    }
}
