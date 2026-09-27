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
        XCTAssertNil(viewModel.roundEnded)
        date.now = startDate.addingTimeInterval(60)
        viewModel.tick()
        XCTAssertEqual(repository.game?.currentRound.phase, .ended(.timeUp))
        XCTAssertFalse(viewModel.isTicking)
        XCTAssertEqual(viewModel.roundEnded?.title, "انتهى الوقت")
        XCTAssertEqual(viewModel.roundEnded?.pointsLine, "لا نقاط في هذه الجولة")
    }

    func testTickingBeforeDescribingDoesNothing() {
        let repository = repository(phase: .wordDrawn)
        let viewModel = makeViewModel(repository: repository, date: MutableDate(startDate.addingTimeInterval(500)))
        XCTAssertFalse(viewModel.isTicking)
        viewModel.tick()
        XCTAssertEqual(repository.saveCount, 0)
    }

    // MARK: - Round end

    func testACorrectGuessShowsTheWinnerAndPoints() {
        let repository = GameRepositoryFake(game: GameFixtures.game(playerCount: 3, marks: [ClueMark(tileIndex: 0, tag: .mainIdea)]))
        let viewModel = makeViewModel(repository: repository)
        GameFixtures.makeUseCases(repository: repository).guess.submit("وحيد القرن", by: guesserId, now: startDate)
        XCTAssertEqual(viewModel.roundEnded, RoundEndedCard.Model(
            title: "تخمين صحيح من لاعب1!",
            wordLine: "الكلمة: وحيد القرن",
            pointsLine: "+2 لـلاعب1 · +1 لـلاعب0",
            buttonTitle: "الجولة التالية"
        ))
    }

    func testTheDescriberEndingTheRoundGivesNoPoints() {
        let viewModel = makeViewModel(repository: repository(phase: .ended(.endedByDescriber)))
        XCTAssertEqual(viewModel.roundEnded?.title, "انتهت الجولة")
        XCTAssertEqual(viewModel.roundEnded?.pointsLine, "لا نقاط في هذه الجولة")
    }

    func testTheLastRoundOffersToFinishTheGame() {
        let viewModel = makeViewModel(repository: repository(phase: .ended(.timeUp), playerCount: 3, roundIndex: 2))
        XCTAssertEqual(viewModel.roundEnded?.buttonTitle, "إنهاء اللعبة")
    }

    func testContinuingOpensTheNextDescribersRound() {
        let repository = repository(phase: .ended(.timeUp))
        let exits = ExitCounter()
        let viewModel = makeViewModel(repository: repository, viewer: guesserId, exits: exits)
        viewModel.continueAfterRound()
        XCTAssertEqual(repository.game?.currentRound.index, 1)
        XCTAssertEqual(repository.game?.currentRound.describerId, guesserId)
        XCTAssertEqual(viewModel.screen, .difficultyPicker, "the viewer describes next")
        XCTAssertNil(viewModel.roundEnded)
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
