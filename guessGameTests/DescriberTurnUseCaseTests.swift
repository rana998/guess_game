import XCTest
@testable import guessGame

final class DescriberTurnUseCaseTests: XCTestCase {
    private let startDate = GameFixtures.startDate
    private let describerId = GameFixtures.playerId(0)
    private let guesserId = GameFixtures.playerId(1)

    private func useCase(
        repository: GameRepositoryFake,
        words: [Difficulty: [String]] = [.medium: ["زرافة", "بطريق", "خيمة"]],
        wordIndex: Int = 0
    ) -> DescriberTurnUseCaseImpl {
        DescriberTurnUseCaseImpl(
            repository: repository,
            wordRepository: WordRepositoryStub(wordsByDifficulty: words),
            wordPicker: RandomIndexPicker { _ in wordIndex }
        )
    }

    private func choosingGame() -> Game {
        GameFixtures.game(phase: .choosingWord, difficulty: nil, word: nil, endsAt: nil)
    }

    // MARK: - Draw word

    func testDrawingSetsTheWordAndDifficulty() {
        let repository = GameRepositoryFake(game: choosingGame())
        XCTAssertTrue(useCase(repository: repository, wordIndex: 1).drawWord(difficulty: .medium, by: describerId))
        let round = repository.game?.currentRound
        XCTAssertEqual(round?.word, "بطريق")
        XCTAssertEqual(round?.difficulty, .medium)
        XCTAssertEqual(round?.phase, .wordDrawn)
        XCTAssertEqual(repository.game?.usedWords, ["بطريق"])
    }

    func testOnlyTheDescriberDraws() {
        let repository = GameRepositoryFake(game: choosingGame())
        XCTAssertFalse(useCase(repository: repository).drawWord(difficulty: .medium, by: guesserId))
        XCTAssertEqual(repository.saveCount, 0)
    }

    func testDrawingOnlyHappensOnce() {
        let repository = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn))
        XCTAssertFalse(useCase(repository: repository).drawWord(difficulty: .medium, by: describerId))
        XCTAssertEqual(repository.saveCount, 0)
    }

    func testNoWordRepeatsWithinAGame() {
        let repository = GameRepositoryFake(game: choosingGame())
        let describerTurn = useCase(repository: repository, wordIndex: 0)
        var drawnWords: [String] = []
        for _ in 0..<3 {
            describerTurn.drawWord(difficulty: .medium, by: describerId)
            drawnWords.append(repository.game?.currentRound.word ?? "")
            guard var game = repository.game else { return XCTFail("no game") }
            game.currentRound.phase = .choosingWord
            repository.save(game)
        }
        XCTAssertEqual(Set(drawnWords).count, 3)
    }

    func testAnExhaustedLevelStartsOver() {
        var game = choosingGame()
        game.usedWords = ["زرافة", "بطريق", "خيمة"]
        let repository = GameRepositoryFake(game: game)
        XCTAssertTrue(useCase(repository: repository).drawWord(difficulty: .medium, by: describerId))
        XCTAssertEqual(repository.game?.currentRound.word, "زرافة")
    }

    func testAnEmptyLevelDrawsNothing() {
        let repository = GameRepositoryFake(game: choosingGame())
        XCTAssertFalse(useCase(repository: repository).drawWord(difficulty: .hard, by: describerId))
        XCTAssertEqual(repository.saveCount, 0)
    }

    // MARK: - Start describing

    func testStartingSetsTheDeadlineFromTheRoundLength() {
        let repository = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn, endsAt: nil, roundSeconds: 60))
        XCTAssertTrue(useCase(repository: repository).startDescribing(by: describerId, now: startDate))
        XCTAssertEqual(repository.game?.currentRound.phase, .describing)
        XCTAssertEqual(repository.game?.currentRound.endsAt, startDate.addingTimeInterval(60))
    }

    func testStartingNeedsADrawnWordAndTheDescriber() {
        let choosing = GameRepositoryFake(game: choosingGame())
        XCTAssertFalse(useCase(repository: choosing).startDescribing(by: describerId, now: startDate))
        let drawn = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn, endsAt: nil))
        XCTAssertFalse(useCase(repository: drawn).startDescribing(by: guesserId, now: startDate))
        XCTAssertEqual(choosing.saveCount + drawn.saveCount, 0)
    }

    // MARK: - Place marks

    func testPlacingKeepsMarksInOrderAcrossTags() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        let describerTurn = useCase(repository: repository)
        XCTAssertEqual(describerTurn.placeMark(.detail, onTile: 4, by: describerId), .placed)
        XCTAssertEqual(describerTurn.placeMark(.mainIdea, onTile: 0, by: describerId), .placed)
        XCTAssertEqual(describerTurn.placeMark(.secondaryIdea, onTile: 9, by: describerId), .placed)
        XCTAssertEqual(describerTurn.placeMark(.detail, onTile: 12, by: describerId), .placed)
        XCTAssertEqual(repository.game?.currentRound.marks, [
            ClueMark(tileIndex: 4, tag: .detail),
            ClueMark(tileIndex: 0, tag: .mainIdea),
            ClueMark(tileIndex: 9, tag: .secondaryIdea),
            ClueMark(tileIndex: 12, tag: .detail),
        ])
    }

    func testTheCapsAreEnforcedWhenPlacing() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        let describerTurn = useCase(repository: repository)
        for tileIndex in 0..<10 {
            XCTAssertEqual(describerTurn.placeMark(.detail, onTile: tileIndex, by: describerId), .placed)
        }
        XCTAssertEqual(describerTurn.placeMark(.detail, onTile: 10, by: describerId), .rejected(.limitReached))
        XCTAssertEqual(describerTurn.placeMark(.mainIdea, onTile: 11, by: describerId), .placed)
        XCTAssertEqual(describerTurn.placeMark(.mainIdea, onTile: 12, by: describerId), .rejected(.limitReached))
        XCTAssertEqual(describerTurn.placeMark(.secondaryIdea, onTile: 13, by: describerId), .placed)
        XCTAssertEqual(describerTurn.placeMark(.secondaryIdea, onTile: 14, by: describerId), .rejected(.limitReached))
        XCTAssertEqual(repository.game?.currentRound.marks.count, 12)
        XCTAssertEqual(repository.saveCount, 12, "refusals save nothing")
    }

    func testOnlyTheDescriberPlaces() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        XCTAssertEqual(useCase(repository: repository).placeMark(.detail, onTile: 0, by: guesserId), .rejected(.notDescriber))
        XCTAssertEqual(repository.saveCount, 0)
    }

    func testPlacingWithoutAGameIsRefused() {
        XCTAssertEqual(useCase(repository: GameRepositoryFake()).placeMark(.detail, onTile: 0, by: describerId), .rejected(.noGame))
    }

    func testRuleRejectionsPassThrough() {
        let repository = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn))
        XCTAssertEqual(useCase(repository: repository).placeMark(.detail, onTile: 0, by: describerId), .rejected(.notDescribing))
        XCTAssertEqual(repository.saveCount, 0)
    }

    // MARK: - End round

    func testEndingTheRoundGivesNoPoints() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        let endDate = startDate.addingTimeInterval(12)
        XCTAssertTrue(useCase(repository: repository).endRound(by: describerId, now: endDate))
        XCTAssertEqual(repository.game?.currentRound.phase, .ended(.endedByDescriber))
        XCTAssertEqual(repository.game?.currentRound.endedAt, endDate)
        XCTAssertEqual(repository.game?.scores.values.reduce(0, +), 0)
    }

    func testOnlyTheDescriberEndsARoundThatIsRunning() {
        let running = GameRepositoryFake(game: GameFixtures.game())
        XCTAssertFalse(useCase(repository: running).endRound(by: guesserId, now: startDate))
        let drawn = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn))
        XCTAssertFalse(useCase(repository: drawn).endRound(by: describerId, now: startDate))
        XCTAssertEqual(running.saveCount + drawn.saveCount, 0)
    }
}
