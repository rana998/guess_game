import XCTest
@testable import guessGame

final class GuesserBoardViewModelTests: XCTestCase {
    private let startDate = GameFixtures.startDate
    private let describerId = GameFixtures.playerId(2)
    private let guesserId = GameFixtures.playerId(4)

    /// Six players; player 2 describes round 3 of 6 (turn order is room order).
    private func makeViewModel(
        repository: GameRepositoryFake,
        viewerId: String? = nil,
        date: MutableDate? = nil
    ) -> GuesserBoardViewModel {
        let clockDate = date ?? MutableDate(startDate)
        return GuesserBoardViewModel(
            useCases: GameFixtures.makeUseCases(repository: repository),
            viewerId: viewerId ?? guesserId,
            clock: GameClock(currentDate: { clockDate.now })
        )
    }

    private func repository(marks: [ClueMark] = [], guesses: [Guess] = [], phase: RoundPhase = .describing) -> GameRepositoryFake {
        GameRepositoryFake(game: GameFixtures.game(playerCount: 6, roundIndex: 2, phase: phase, marks: marks, guesses: guesses))
    }

    /// The describer tags an image, as their board would.
    private func describerPlaces(_ tag: ClueTag, onTile tileIndex: Int, in repository: GameRepositoryFake) {
        GameFixtures.makeUseCases(repository: repository).describerTurn.placeMark(tag, onTile: tileIndex, by: describerId)
    }

    // MARK: - Header

    func testRoundOfRoundsAndPlayers() {
        let viewModel = makeViewModel(repository: repository())
        XCTAssertEqual(viewModel.roundText, "الجولة 3/6")
        XCTAssertEqual(viewModel.describerAvatar?.id, describerId)
        XCTAssertEqual(viewModel.guesserAvatars.map(\.id), ["player-0", "player-1", "player-3", "player-4", "player-5"])
    }

    func testTimerCountsDownFromTheClock() {
        let date = MutableDate(startDate.addingTimeInterval(13))
        XCTAssertEqual(makeViewModel(repository: repository(), date: date).timerText, "0:47")
    }

    // MARK: - Before the first image

    func testNothingToGuessFromYet() {
        let viewModel = makeViewModel(repository: repository())
        viewModel.typedGuess = "زرافة"
        XCTAssertFalse(viewModel.canSubmit)
        XCTAssertNil(viewModel.submit())
        XCTAssertTrue(viewModel.isGuessListEmpty)
        XCTAssertEqual(viewModel.emptySubtitle, "يمكنك التخمين في أي وقت عند ظهور اول صورة")
        XCTAssertEqual(viewModel.mainBoxCaption, "بانتظار اول صورة")
        XCTAssertEqual(viewModel.placeholderSlotCount, 5)
        XCTAssertNil(viewModel.secondaryTile)
        XCTAssertEqual(viewModel.bottomCaption, "بانتظار أول صورة من لاعب2…")
    }

    // MARK: - Images arriving live

    func testImagesFillTheMainBoxInPlacementOrderAsTheyArrive() {
        let repository = repository()
        let viewModel = makeViewModel(repository: repository)
        describerPlaces(.detail, onTile: 12, in: repository)
        XCTAssertEqual(viewModel.mainSlots.map(\.id), [12])
        XCTAssertNil(viewModel.mainBoxCaption)
        XCTAssertNil(viewModel.bottomCaption)
        describerPlaces(.mainIdea, onTile: 3, in: repository)
        describerPlaces(.detail, onTile: 25, in: repository)
        XCTAssertEqual(viewModel.mainSlots.map(\.id), [12, 3, 25])
        XCTAssertEqual(viewModel.mainSlots.map(\.tag), [.detail, .mainIdea, .detail])
        XCTAssertEqual(viewModel.placeholderSlotCount, 2)
        XCTAssertEqual(viewModel.lastMainSlotId, 25)
    }

    func testTheExclamationGoesToTheSecondaryBoxNotTheMainOne() {
        let repository = repository()
        let viewModel = makeViewModel(repository: repository)
        describerPlaces(.secondaryIdea, onTile: 8, in: repository)
        XCTAssertEqual(viewModel.secondaryTile?.id, 8)
        XCTAssertEqual(viewModel.secondaryTile?.tag, .secondaryIdea)
        XCTAssertEqual(viewModel.mainSlots, [])
        XCTAssertEqual(viewModel.mainBoxCaption, "بانتظار اول صورة")
    }

    func testTheMainBoxHoldsAllElevenImagesWithoutPlaceholders() {
        let repository = repository()
        let viewModel = makeViewModel(repository: repository)
        describerPlaces(.mainIdea, onTile: 0, in: repository)
        for tileIndex in 1...10 {
            describerPlaces(.detail, onTile: tileIndex, in: repository)
        }
        XCTAssertEqual(viewModel.mainSlots.count, 11)
        XCTAssertEqual(viewModel.placeholderSlotCount, 0)
    }

    func testEachNewImageIsAnnounced() {
        let repository = repository()
        let viewModel = makeViewModel(repository: repository)
        XCTAssertEqual(viewModel.markCount, 0)
        describerPlaces(.detail, onTile: 1, in: repository)
        XCTAssertEqual(viewModel.markCount, 1)
        XCTAssertEqual(viewModel.latestMarkAnnouncement, "صورة جديدة: تفصيل إضافي")
    }

    // MARK: - Guessing

    func testAWrongGuessJoinsTheListAndClearsTheField() {
        let repository = repository(marks: [ClueMark(tileIndex: 0, tag: .mainIdea)])
        let viewModel = makeViewModel(repository: repository)
        XCTAssertEqual(viewModel.emptySubtitle, "ظهرت أول صورة. اكتب تخمينك الآن")
        viewModel.typedGuess = "  زرافة "
        XCTAssertTrue(viewModel.canSubmit)
        XCTAssertEqual(viewModel.submit(), .incorrect)
        XCTAssertEqual(viewModel.typedGuess, "")
        XCTAssertEqual(viewModel.guessRows, [
            GuessRow.Model(id: 0, playerName: "لاعب4", text: "زرافة", isCorrect: false, accessibilityLabel: "لاعب4: زرافة"),
        ])
        XCTAssertNil(viewModel.latestGuessAnnouncement, "the viewer's own guess isn't read back")
    }

    func testTheRightGuessIsMarkedAndEndsTheRound() {
        let repository = repository(marks: [ClueMark(tileIndex: 0, tag: .mainIdea)])
        let viewModel = makeViewModel(repository: repository)
        viewModel.typedGuess = "وحيد القرن"
        XCTAssertEqual(viewModel.submit(), .correct)
        XCTAssertEqual(viewModel.guessRows.last?.isCorrect, true)
        XCTAssertEqual(viewModel.guessRows.last?.accessibilityLabel, "لاعب4: وحيد القرن، تخمين صحيح")
        XCTAssertTrue(viewModel.isRoundOver)
        viewModel.typedGuess = "زرافة"
        XCTAssertFalse(viewModel.canSubmit)
    }

    func testOtherPlayersGuessesShowUpLiveOldestFirstAndAreAnnounced() {
        let repository = repository(marks: [ClueMark(tileIndex: 0, tag: .mainIdea)])
        let viewModel = makeViewModel(repository: repository)
        let guessUseCase = GameFixtures.makeUseCases(repository: repository).guess
        guessUseCase.submit("حصان", by: "player-0", now: startDate.addingTimeInterval(5))
        guessUseCase.submit("زرافة", by: "player-5", now: startDate.addingTimeInterval(6))
        XCTAssertEqual(viewModel.guessRows.map(\.text), ["حصان", "زرافة"])
        XCTAssertEqual(viewModel.guessRows.map(\.playerName), ["لاعب0", "لاعب5"])
        XCTAssertEqual(viewModel.guessCount, 2)
        XCTAssertEqual(viewModel.lastGuessId, 1)
        XCTAssertEqual(viewModel.latestGuessAnnouncement, "لاعب5: زرافة")
    }

    func testBlankGuessCannotBeSent() {
        let viewModel = makeViewModel(repository: repository(marks: [ClueMark(tileIndex: 0, tag: .detail)]))
        viewModel.typedGuess = "   "
        XCTAssertFalse(viewModel.canSubmit)
    }

    func testTheDescriberCannotGuessFromThisScreen() {
        let viewModel = makeViewModel(repository: repository(marks: [ClueMark(tileIndex: 0, tag: .detail)]), viewerId: describerId)
        viewModel.typedGuess = "وحيد القرن"
        XCTAssertFalse(viewModel.canSubmit)
    }

    func testAGuessUsesTheTimeOfTheTap() {
        let repository = repository(marks: [ClueMark(tileIndex: 0, tag: .detail)])
        let date = MutableDate(startDate)
        let viewModel = makeViewModel(repository: repository, date: date)
        date.now = startDate.addingTimeInterval(61)
        viewModel.typedGuess = "وحيد القرن"
        XCTAssertEqual(viewModel.submit(), .rejected(.timeUp))
        XCTAssertEqual(viewModel.typedGuess, "وحيد القرن", "a refused guess stays typed")
        XCTAssertEqual(repository.game?.currentRound.guesses, [])
    }
}
