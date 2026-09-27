struct GameLifecycleUseCaseImpl: GameLifecycleUseCase {
    let repository: GameRepository
    let firstDescriberPicker: RandomIndexPicker

    var currentGame: Game? { repository.game }

    @discardableResult
    func start(room: Room) -> Game? {
        guard room.players.count >= Room.minimumPlayers,
              let firstDescriberIndex = firstDescriberPicker.index(below: room.players.count) else { return nil }
        let playerIds = room.players.map(\.id)
        let turnOrder = TurnOrder.rotation(of: playerIds, startingAt: firstDescriberIndex)
        let game = Game(
            players: room.players,
            roundSeconds: room.roundSeconds,
            turnOrder: turnOrder,
            currentRound: Round(index: 0, describerId: turnOrder[0]),
            scores: Dictionary(playerIds.map { playerId in (playerId, 0) }, uniquingKeysWith: { first, _ in first })
        )
        repository.save(game)
        return game
    }

    func advanceToNextRound() {
        guard var game = repository.game, !game.isFinished, game.currentRound.isEnded else { return }
        if game.isLastRound {
            game.isFinished = true
        } else {
            let nextIndex = game.currentRound.index + 1
            game.currentRound = Round(index: nextIndex, describerId: game.turnOrder[nextIndex])
        }
        repository.save(game)
    }

    func leave() {
        repository.clear()
    }
}
