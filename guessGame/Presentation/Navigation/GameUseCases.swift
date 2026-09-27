/// Everything the round screens may do to a game. View models read the game
/// through `lifecycle.currentGame` and change it only through these use cases,
/// never by saving it themselves.
struct GameUseCases {
    let lifecycle: GameLifecycleUseCase
    let describerTurn: DescriberTurnUseCase
    let guess: GuessUseCase
    let roundTimer: RoundTimerUseCase
}
