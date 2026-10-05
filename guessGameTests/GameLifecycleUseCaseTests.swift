import XCTest
@testable import guessGame

final class GameLifecycleUseCaseTests: XCTestCase {
    private func room(playerCount: Int, roundSeconds: Int = 90) -> Room {
        Room(code: "1234", capacity: 6, players: GameFixtures.players(count: playerCount), roundSeconds: roundSeconds)
    }

    private func useCase(repository: GameRepositoryFake, firstDescriberIndex: Int = 0) -> GameLifecycleUseCaseImpl {
        GameLifecycleUseCaseImpl(repository: repository, firstDescriberPicker: RandomIndexPicker { _ in firstDescriberIndex })
    }

    /// Ends the current round the way a timeout would.
    private func endCurrentRound(in repository: GameRepositoryFake) {
        guard var game = repository.game else { return XCTFail("no game") }
        game.currentRound.phase = .ended(.timeUp)
        repository.save(game)
    }

    // MARK: - Start

    func testTooFewPlayersStartsNothing() {
        let repository = GameRepositoryFake()
        XCTAssertNil(useCase(repository: repository).start(room: room(playerCount: 2)))
        XCTAssertNil(repository.game)
        XCTAssertEqual(repository.saveCount, 0)
    }

    func testThePickerChoosesAmongAllPlayers() {
        var askedCount: Int?
        let picker = RandomIndexPicker { count in
            askedCount = count
            return 0
        }
        GameLifecycleUseCaseImpl(repository: GameRepositoryFake(), firstDescriberPicker: picker).start(room: room(playerCount: 5))
        XCTAssertEqual(askedCount, 5)
    }

    func testTheRandomFirstDescriberStartsTheRotation() {
        let repository = GameRepositoryFake()
        let game = useCase(repository: repository, firstDescriberIndex: 2).start(room: room(playerCount: 4))
        XCTAssertEqual(game?.turnOrder, ["player-2", "player-3", "player-0", "player-1"])
        XCTAssertEqual(game?.currentRound.describerId, "player-2")
        XCTAssertEqual(repository.game, game)
    }

    func testANewGameStartsWithTheWordChoiceAndNoPoints() {
        let game = useCase(repository: GameRepositoryFake()).start(room: room(playerCount: 3, roundSeconds: 30))
        XCTAssertEqual(game?.currentRound.index, 0)
        XCTAssertEqual(game?.currentRound.phase, .choosingWord)
        XCTAssertEqual(game?.scores, ["player-0": 0, "player-1": 0, "player-2": 0])
        XCTAssertEqual(game?.roundSeconds, 30)
        XCTAssertEqual(game?.roundCount, 3)
        XCTAssertEqual(game?.usedWords, [])
    }

    func testCurrentGameReadsTheRepository() {
        let repository = GameRepositoryFake()
        let lifecycle = useCase(repository: repository)
        XCTAssertNil(lifecycle.currentGame)
        lifecycle.start(room: room(playerCount: 3))
        XCTAssertEqual(lifecycle.currentGame, repository.game)
    }

    // MARK: - Advance

    func testCannotAdvanceBeforeTheRoundEnds() {
        let repository = GameRepositoryFake()
        let lifecycle = useCase(repository: repository)
        lifecycle.start(room: room(playerCount: 3))
        let savesBefore = repository.saveCount
        lifecycle.advanceToNextRound()
        XCTAssertEqual(repository.game?.currentRound.index, 0)
        XCTAssertEqual(repository.saveCount, savesBefore)
    }

    func testAdvancingHandsTheNextRoundToTheNextDescriber() {
        let repository = GameRepositoryFake()
        let lifecycle = useCase(repository: repository, firstDescriberIndex: 1)
        lifecycle.start(room: room(playerCount: 4))
        guard var game = repository.game else { return XCTFail("no game") }
        game.currentRound.marks = [ClueMark(tileIndex: 0, tag: .detail)]
        game.currentRound.phase = .ended(.guessed(winnerId: "player-2"))
        game.scores["player-2"] = 2
        game.usedWords = ["قطة"]
        repository.save(game)

        lifecycle.advanceToNextRound()

        let nextGame = repository.game
        XCTAssertEqual(nextGame?.currentRound.index, 1)
        XCTAssertEqual(nextGame?.currentRound.describerId, "player-2")
        XCTAssertEqual(nextGame?.currentRound.phase, .choosingWord)
        XCTAssertEqual(nextGame?.currentRound.marks, [])
        XCTAssertEqual(nextGame?.currentRound.guesses, [])
        XCTAssertNil(nextGame?.currentRound.word)
        XCTAssertEqual(nextGame?.scores["player-2"], 2, "scores carry over")
        XCTAssertEqual(nextGame?.usedWords, ["قطة"], "used words carry over")
    }

    func testEveryPlayerDescribesExactlyOnceThenTheGameFinishes() {
        let repository = GameRepositoryFake()
        let lifecycle = useCase(repository: repository, firstDescriberIndex: 3)
        lifecycle.start(room: room(playerCount: 5))
        var describers: [String] = []
        for _ in 0..<5 {
            describers.append(repository.game?.currentRound.describerId ?? "")
            XCTAssertEqual(repository.game?.isFinished, false)
            endCurrentRound(in: repository)
            lifecycle.advanceToNextRound()
        }
        XCTAssertEqual(describers, ["player-3", "player-4", "player-0", "player-1", "player-2"])
        XCTAssertEqual(repository.game?.isFinished, true)
        XCTAssertEqual(repository.game?.currentRound.index, 4, "the last round stays on show")
    }

    func testAdvancingAFinishedGameDoesNothing() {
        let repository = GameRepositoryFake()
        let lifecycle = useCase(repository: repository)
        lifecycle.start(room: room(playerCount: 3))
        for _ in 0..<3 {
            endCurrentRound(in: repository)
            lifecycle.advanceToNextRound()
        }
        let savesBefore = repository.saveCount
        lifecycle.advanceToNextRound()
        XCTAssertEqual(repository.saveCount, savesBefore)
    }

    // MARK: - Leave

    func testLeavingClearsTheGame() {
        let repository = GameRepositoryFake()
        let lifecycle = useCase(repository: repository)
        lifecycle.start(room: room(playerCount: 3))
        lifecycle.leave()
        XCTAssertNil(repository.game)
    }
}
