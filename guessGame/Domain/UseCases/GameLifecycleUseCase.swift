/// Starting a game from a room, moving from one round to the next, and leaving.
protocol GameLifecycleUseCase {
    var currentGame: Game? { get }
    /// nil, and nothing saved, when the room has too few players.
    @discardableResult func start(room: Room) -> Game?
    /// Opens the next describer's round once the current one has ended, or
    /// finishes the game after the last round.
    func advanceToNextRound()
    func leave()
}
