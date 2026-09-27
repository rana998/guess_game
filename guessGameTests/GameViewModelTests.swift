import XCTest
@testable import guessGame

final class GameViewModelTests: XCTestCase {
    private let startDate = GameFixtures.startDate
    private let describerId = GameFixtures.playerId(0)
    private let guesserId = GameFixtures.playerId(1)

    private final class ExitCounter {
        var count = 0
    }

    private func makeViewModel(
        repository: GameRepositoryFake,
        viewer: String? = nil,
        date: MutableDate? = nil,
        exits: ExitCounter = ExitCounter()
    ) -> GameViewModel {
        let clockDate = date ?? MutableDate(startDate)
        return GameViewModel(
            useCases: GameFixtures.makeUseCases(repository: repository),
            viewerId: viewer ?? guesserId,
            clock: GameClock(currentDate: { clockDate.now }),
            onExit: { exits.count += 1 }
        )
    }

    private func repository(phase: RoundPhase, playerCount: Int = 3, roundIndex: Int = 0) -> GameRepositoryFake {
        GameRepositoryFake(game: GameFixtures.game(playerCount: playerCount, roundIndex: roundIndex, phase: phase))
    }

    // MARK: - Routing

    func testEachRoleSeesItsScreenInEachPhase() {
        let expectations: [(RoundPhase, GameScreen, GameScreen)] = [
            (.choosingWord, .difficultyPicker, .waitingForWord),
            (.wordDrawn, .wordCard, .waitingForWord),
            (.describing, .describerBoard, .guesserBoard),
            (.ended(.timeUp), .describerBoard, .guesserBoard),
        ]
        for (phase, describerScreen, guesserScreen) in expectations {
            XCTAssertEqual(makeViewModel(repository: repository(phase: phase), viewer: describerId).screen, describerScreen, "\(phase)")
            XCTAssertEqual(makeViewModel(repository: repository(phase: phase), viewer: guesserId).screen, guesserScreen, "\(phase)")
        }
    }

    func testNoGameNoScreen() {
        XCTAssertNil(makeViewModel(repository: GameRepositoryFake()).screen)
    }

    func testScreenIdentityChangesWithViewerRoundAndScreenOnly() {
        let repository = repository(phase: .describing)
        let viewModel = makeViewModel(repository: repository)
        let initial = viewModel.screenIdentity
        let useCases = GameFixtures.makeUseCases(repository: repository)
        useCases.describerTurn.placeMark(.detail, onTile: 0, by: describerId)
        useCases.guess.submit("زرافة", by: guesserId, now: startDate)
        XCTAssertEqual(viewModel.screenIdentity, initial, "live moves keep the screen's state")

        viewModel.switchViewer(to: describerId)
        XCTAssertNotEqual(viewModel.screenIdentity, initial)

        let roundOne = repository.game?.currentRound.index
        useCases.describerTurn.endRound(by: describerId, now: startDate)
        useCases.lifecycle.advanceToNextRound()
        XCTAssertNotEqual(repository.game?.currentRound.index, roundOne)
        XCTAssertEqual(viewModel.screenIdentity?.roundIndex, 1)
    }

    // MARK: - Timer

    func testTickingEndsTheRoundWhenTimeRunsOut() {
        let repository = repository(phase: .describing)
        let date = MutableDate(startDate)
        let viewModel = makeViewModel(repository: repository, date: date)
        XCTAssertTrue(viewModel.isTicking)
        date.now = startDate.addingTimeInterval(59)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.phase, .describing)
        date.now = startDate.addingTimeInterval(60)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.phase, .ended(.timeUp))
        XCTAssertTrue(viewModel.isTicking, "keeps ticking to move on after the pause")
    }

    func testTickingBeforeDescribingDoesNothing() {
        let repository = repository(phase: .wordDrawn)
        let viewModel = makeViewModel(repository: repository, date: MutableDate(startDate.addingTimeInterval(500)))
        XCTAssertFalse(viewModel.isTicking)
        viewModel.tick()
        XCTAssertEqual(repository.saveCount, 0)
    }

    // MARK: - Round end

    func testContinuingOpensTheNextDescribersRound() {
        let repository = repository(phase: .ended(.timeUp))
        let exits = ExitCounter()
        let viewModel = makeViewModel(repository: repository, viewer: guesserId, exits: exits)
        viewModel.continueAfterRound()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
        XCTAssertEqual(repository.game?.currentRound.describerId, guesserId)
        XCTAssertEqual(viewModel.screen, .difficultyPicker, "the viewer describes next")
        XCTAssertEqual(exits.count, 0)
    }

    func testContinuingAfterTheLastRoundLeavesTheGameOnce() {
        let repository = repository(phase: .ended(.timeUp), playerCount: 3, roundIndex: 2)
        let exits = ExitCounter()
        let viewModel = makeViewModel(repository: repository, exits: exits)
        viewModel.continueAfterRound()
        XCTAssertEqual(exits.count, 1)
        XCTAssertNil(repository.game)
        viewModel.continueAfterRound()
        viewModel.confirmLeave()
        XCTAssertEqual(exits.count, 1)
    }

    // MARK: - Moving on after a round

    private func endedRepository(reason: RoundEndReason = .endedByDescriber, roundIndex: Int = 0, endedAt: Date?) -> GameRepositoryFake {
        GameRepositoryFake(game: GameFixtures.game(playerCount: 3, roundIndex: roundIndex, phase: .ended(reason), endedAt: endedAt))
    }

    func testAnEndedRoundStaysUntilThePauseIsOver() {
        let repository = endedRepository(endedAt: startDate)
        let date = MutableDate(startDate.addingTimeInterval(3.9))
        let viewModel = makeViewModel(repository: repository, date: date)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 0)
        XCTAssertEqual(viewModel.screen, .guesserBoard)
        date.now = startDate.addingTimeInterval(GameViewModel.roundEndPause)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
        XCTAssertEqual(repository.game?.currentRound.phase, .choosingWord)
    }

    func testTimeRunningOutMovesOnAfterThePause() {
        let repository = repository(phase: .describing)
        let date = MutableDate(startDate.addingTimeInterval(60))
        let viewModel = makeViewModel(repository: repository, date: date)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.phase, .ended(.timeUp))
        date.now = startDate.addingTimeInterval(63.9)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 0)
        date.now = startDate.addingTimeInterval(64)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
    }

    func testACorrectGuessMovesOnAfterThePause() {
        let repository = GameRepositoryFake(game: GameFixtures.game(playerCount: 3, marks: [ClueMark(tileIndex: 0, tag: .mainIdea)]))
        let date = MutableDate(startDate.addingTimeInterval(10))
        let viewModel = makeViewModel(repository: repository, date: date)
        GameFixtures.makeUseCases(repository: repository).guess.submit("وحيد القرن", by: guesserId, now: date.now)
        date.now = startDate.addingTimeInterval(13.9)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.guesses.last?.isCorrect, true, "the checked guess stays on show")
        XCTAssertEqual(repository.game?.currentRound.index, 0)
        date.now = startDate.addingTimeInterval(14)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
    }

    func testTheLastRoundReturnsHomeAfterThePause() {
        let repository = endedRepository(roundIndex: 2, endedAt: startDate)
        let exits = ExitCounter()
        let date = MutableDate(startDate.addingTimeInterval(4))
        let viewModel = makeViewModel(repository: repository, date: date, exits: exits)
        viewModel.tick()
        XCTAssertEqual(exits.count, 1)
        XCTAssertNil(repository.game)
        XCTAssertFalse(viewModel.isTicking)
        viewModel.tick()
        XCTAssertEqual(exits.count, 1)
    }

    func testNoMovingOnWhileLeavingIsBeingConfirmed() {
        let repository = endedRepository(endedAt: startDate)
        let viewModel = makeViewModel(repository: repository, date: MutableDate(startDate.addingTimeInterval(10)))
        viewModel.requestLeave()
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 0)
        viewModel.isConfirmingLeave = false
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
    }

    func testAnEndedRoundWithoutAnEndTimeMovesOnAtOnce() {
        let repository = endedRepository(endedAt: nil)
        let viewModel = makeViewModel(repository: repository)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
    }

    // MARK: - Leaving

    func testLeavingAsksFirstThenClearsTheGame() {
        let repository = repository(phase: .describing)
        let exits = ExitCounter()
        let viewModel = makeViewModel(repository: repository, exits: exits)
        viewModel.requestLeave()
        XCTAssertTrue(viewModel.isConfirmingLeave)
        XCTAssertNotNil(repository.game)
        viewModel.confirmLeave()
        XCTAssertNil(repository.game)
        XCTAssertEqual(exits.count, 1)
    }

    // MARK: - Viewer

    func testSwitchingToTheDescriberShowsTheirScreen() {
        let viewModel = makeViewModel(repository: repository(phase: .choosingWord))
        XCTAssertEqual(viewModel.screen, .waitingForWord)
        viewModel.switchViewer(to: describerId)
        XCTAssertEqual(viewModel.screen, .difficultyPicker)
        XCTAssertEqual(viewModel.viewerAvatar?.id, describerId)
    }

    func testUnknownViewerIsIgnored() {
        let viewModel = makeViewModel(repository: repository(phase: .describing))
        viewModel.switchViewer(to: "stranger")
        XCTAssertEqual(viewModel.viewerId, guesserId)
    }

    func testViewerChoicesNameTheDescriber() {
        let viewModel = makeViewModel(repository: repository(phase: .describing))
        XCTAssertEqual(viewModel.viewerChoices.map(\.title), ["لاعب0 (الواصف)", "لاعب1", "لاعب2"])
    }
}
