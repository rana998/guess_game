// Pure comparison logic over an already-known target — no repository needed,
// unlike StartGameUseCase which must obtain a fresh random number from outside Domain.
final class MakeGuessUseCaseImpl: MakeGuessUseCase {
    func execute(guess: Int, in session: GameSession) -> (outcome: GuessOutcome, session: GameSession) {
        var updated = session
        updated.attemptCount += 1

        let outcome: GuessOutcome
        if guess < session.targetNumber {
            outcome = .tooLow
        } else if guess > session.targetNumber {
            outcome = .tooHigh
        } else {
            outcome = .correct
            updated.isFinished = true
        }
        return (outcome, updated)
    }
}
