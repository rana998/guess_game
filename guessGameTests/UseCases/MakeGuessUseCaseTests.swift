import XCTest
@testable import guessGame

final class MakeGuessUseCaseTests: XCTestCase {
    private func makeSession(target: Int, attemptCount: Int = 0) -> GameSession {
        GameSession(id: UUID(), targetNumber: target, range: 1...100, attemptCount: attemptCount, isFinished: false)
    }

    func test_guessBelowTarget_returnsTooLow() {
        let sut = MakeGuessUseCaseImpl()
        let result = sut.execute(guess: 10, in: makeSession(target: 50))
        XCTAssertEqual(result.outcome, .tooLow)
    }

    func test_guessAboveTarget_returnsTooHigh() {
        let sut = MakeGuessUseCaseImpl()
        let result = sut.execute(guess: 90, in: makeSession(target: 50))
        XCTAssertEqual(result.outcome, .tooHigh)
    }

    func test_guessEqualToTarget_returnsCorrectAndMarksSessionFinished() {
        let sut = MakeGuessUseCaseImpl()
        let result = sut.execute(guess: 50, in: makeSession(target: 50))
        XCTAssertEqual(result.outcome, .correct)
        XCTAssertTrue(result.session.isFinished)
    }

    func test_everyGuess_incrementsAttemptCount() {
        let sut = MakeGuessUseCaseImpl()
        let first = sut.execute(guess: 10, in: makeSession(target: 50))
        let second = sut.execute(guess: 20, in: first.session)
        XCTAssertEqual(second.session.attemptCount, 2)
    }

    func test_incorrectGuess_doesNotMarkSessionFinished() {
        let sut = MakeGuessUseCaseImpl()
        let result = sut.execute(guess: 10, in: makeSession(target: 50))
        XCTAssertFalse(result.session.isFinished)
    }
}
