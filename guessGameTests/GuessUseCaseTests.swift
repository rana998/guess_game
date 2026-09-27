import XCTest
@testable import guessGame

final class GuessUseCaseTests: XCTestCase {
    private let startDate = GameFixtures.startDate
    private let describerId = GameFixtures.playerId(0)
    private let guesserId = GameFixtures.playerId(1)
    private let oneMark = [ClueMark(tileIndex: 0, tag: .mainIdea)]

    private func useCase(_ repository: GameRepositoryFake) -> GuessUseCaseImpl {
        GuessUseCaseImpl(repository: repository, matcher: GuessMatcher())
    }

    private func describingRepository(difficulty: Difficulty = .medium, marks: [ClueMark]? = nil) -> GameRepositoryFake {
        GameRepositoryFake(game: GameFixtures.game(marks: marks ?? oneMark, difficulty: difficulty))
    }

    private var duringTheRound: Date { startDate.addingTimeInterval(10) }

    // MARK: - Refusals

    func testRefusalsStoreNothing() {
        let cases: [(GameRepositoryFake, String, String, Date, GuessRejection)] = [
            (GameRepositoryFake(), "زرافة", guesserId, duringTheRound, .noGame),
            (GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn, marks: oneMark)), "زرافة", guesserId, duringTheRound, .notDescribing),
            (describingRepository(), "زرافة", "stranger", duringTheRound, .unknownPlayer),
            (describingRepository(), "زرافة", describerId, duringTheRound, .describerCannotGuess),
            (describingRepository(marks: []), "زرافة", guesserId, duringTheRound, .noClueYet),
            (describingRepository(), "   \n ", guesserId, duringTheRound, .empty),
        ]
        for (repository, text, playerId, date, rejection) in cases {
            XCTAssertEqual(useCase(repository).submit(text, by: playerId, now: date), .rejected(rejection))
            XCTAssertEqual(repository.saveCount, 0, "\(rejection)")
            XCTAssertEqual(repository.game?.currentRound.guesses ?? [], [])
        }
    }

    func testAGuessAtTheDeadlineIsTooLate() {
        let repository = describingRepository()
        XCTAssertEqual(useCase(repository).submit("زرافة", by: guesserId, now: startDate.addingTimeInterval(60)), .rejected(.timeUp))
        XCTAssertEqual(repository.saveCount, 0)
        XCTAssertEqual(useCase(repository).submit("زرافة", by: guesserId, now: startDate.addingTimeInterval(59.9)), .incorrect)
    }

    // MARK: - Wrong guesses

    func testAWrongGuessIsRecordedAndTheRoundGoesOn() {
        let repository = describingRepository()
        XCTAssertEqual(useCase(repository).submit("  زرافة ", by: guesserId, now: duringTheRound), .incorrect)
        XCTAssertEqual(repository.game?.currentRound.guesses, [Guess(id: 0, playerId: guesserId, text: "زرافة", isCorrect: false)])
        XCTAssertEqual(repository.game?.currentRound.phase, .describing)
    }

    func testWrongGuessesAreUnlimitedAndNumberedInOrder() {
        let repository = describingRepository()
        for attempt in 0..<20 {
            XCTAssertEqual(useCase(repository).submit("خطأ\(attempt)", by: guesserId, now: duringTheRound), .incorrect)
        }
        XCTAssertEqual(repository.game?.currentRound.guesses.map(\.id), Array(0..<20))
    }

    // MARK: - Correct guesses

    func testTheFirstCorrectGuessScoresAndEndsTheRound() {
        let repository = describingRepository(difficulty: .medium)
        useCase(repository).submit("زرافة", by: GameFixtures.playerId(2), now: duringTheRound)
        XCTAssertEqual(useCase(repository).submit("وحيد القرن", by: guesserId, now: duringTheRound), .correct)
        let game = repository.game
        XCTAssertEqual(game?.currentRound.phase, .ended(.guessed(winnerId: guesserId)))
        XCTAssertEqual(game?.currentRound.endedAt, duringTheRound)
        XCTAssertEqual(game?.scores[guesserId], 2)
        XCTAssertEqual(game?.scores[describerId], 1)
        XCTAssertEqual(game?.scores[GameFixtures.playerId(2)], 0)
        XCTAssertEqual(game?.currentRound.awardedPoints, [guesserId: 2, describerId: 1])
        XCTAssertEqual(game?.currentRound.guesses.last?.isCorrect, true)
    }

    func testPointsFollowTheDifficulty() {
        for (difficulty, points) in [(Difficulty.easy, 1), (.hard, 3)] {
            let repository = describingRepository(difficulty: difficulty)
            useCase(repository).submit("وحيد القرن", by: guesserId, now: duringTheRound)
            XCTAssertEqual(repository.game?.scores[guesserId], points)
        }
    }

    func testSpellingVariantsCountAsCorrect() {
        let repository = describingRepository()
        XCTAssertEqual(useCase(repository).submit("وَحيدُ القَرن", by: guesserId, now: duringTheRound), .correct)
    }

    func testNoGuessesAfterTheRoundEnds() {
        let repository = describingRepository()
        useCase(repository).submit("وحيد القرن", by: guesserId, now: duringTheRound)
        XCTAssertEqual(useCase(repository).submit("وحيد القرن", by: GameFixtures.playerId(2), now: duringTheRound), .rejected(.notDescribing))
        XCTAssertEqual(repository.game?.scores[GameFixtures.playerId(2)], 0)
    }
}
