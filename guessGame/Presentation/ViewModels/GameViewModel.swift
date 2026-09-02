import Foundation

@Observable
final class GameViewModel {
    private let startGameUseCase: StartGameUseCase
    private let makeGuessUseCase: MakeGuessUseCase

    var session: GameSession?
    var guessInput: String = ""
    var feedbackMessage: String = "Guess a number!"
    var isGameOver: Bool = false

    init(startGameUseCase: StartGameUseCase, makeGuessUseCase: MakeGuessUseCase) {
        self.startGameUseCase = startGameUseCase
        self.makeGuessUseCase = makeGuessUseCase
    }

    func startNewGame() {
        session = startGameUseCase.execute(range: 1...100)
        guessInput = ""
        feedbackMessage = "Guess a number between 1 and 100!"
        isGameOver = false
    }

    func submitGuess() {
        guard let session, let guess = Int(guessInput) else {
            feedbackMessage = "Enter a valid number."
            return
        }
        let result = makeGuessUseCase.execute(guess: guess, in: session)
        self.session = result.session
        isGameOver = result.session.isFinished
        switch result.outcome {
        case .tooLow: feedbackMessage = "Too low, try again."
        case .tooHigh: feedbackMessage = "Too high, try again."
        case .correct: feedbackMessage = "Correct! It took \(result.session.attemptCount) attempts."
        }
        guessInput = ""
    }
}
