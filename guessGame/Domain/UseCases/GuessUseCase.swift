import Foundation

/// A guesser's attempt at the secret word. The first correct guess scores and
/// ends the round; wrong guesses are recorded without limit.
protocol GuessUseCase {
    @discardableResult func submit(_ text: String, by playerId: String, now: Date) -> GuessResult
}
