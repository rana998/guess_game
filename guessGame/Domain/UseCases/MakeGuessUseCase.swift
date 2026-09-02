protocol MakeGuessUseCase {
    func execute(guess: Int, in session: GameSession) -> (outcome: GuessOutcome, session: GameSession)
}
