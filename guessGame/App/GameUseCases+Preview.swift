#if DEBUG
extension GameUseCases {
    /// Live use cases over a store already holding `game`, for previews and snapshots.
    static func preview(seededWith game: Game) -> GameUseCases {
        let repository = GameRepositoryImpl()
        repository.save(game)
        return make(gameRepository: repository, wordRepository: WordRepositoryImpl(), firstDescriberPicker: .system, wordPicker: .system)
    }
}
#endif
