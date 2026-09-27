/// Wires the game's use cases to their stores: the one place outside Data
/// that knows the concrete repositories.
extension GameUseCases {
    static func make(
        gameRepository: GameRepository,
        wordRepository: WordRepository,
        firstDescriberPicker: RandomIndexPicker,
        wordPicker: RandomIndexPicker
    ) -> GameUseCases {
        GameUseCases(
            lifecycle: GameLifecycleUseCaseImpl(repository: gameRepository, firstDescriberPicker: firstDescriberPicker),
            describerTurn: DescriberTurnUseCaseImpl(repository: gameRepository, wordRepository: wordRepository, wordPicker: wordPicker),
            guess: GuessUseCaseImpl(repository: gameRepository, matcher: GuessMatcher()),
            roundTimer: RoundTimerUseCaseImpl(repository: gameRepository)
        )
    }

    /// One in-memory game shared by every screen on this device.
    static func live() -> GameUseCases {
        make(
            gameRepository: GameRepositoryImpl(),
            wordRepository: WordRepositoryImpl(),
            firstDescriberPicker: .system,
            wordPicker: .system
        )
    }
}
