import XCTest
@testable import guessGame

final class DescriberBoardViewModelTests: XCTestCase {
    private let describerId = GameFixtures.playerId(0)
    private let startDate = GameFixtures.startDate

    private func makeViewModel(
        repository: GameRepositoryFake,
        viewerId: String? = nil,
        date: MutableDate? = nil
    ) -> DescriberBoardViewModel {
        let clockDate = date ?? MutableDate(startDate)
        return DescriberBoardViewModel(
            useCases: GameFixtures.makeUseCases(repository: repository),
            viewerId: viewerId ?? describerId,
            clock: GameClock(currentDate: { clockDate.now })
        )
    }

    private func describingRepository(marks: [ClueMark] = []) -> GameRepositoryFake {
        GameRepositoryFake(game: GameFixtures.game(marks: marks))
    }

    /// Opens the picker on a tile and chooses a tag, as the describer would.
    @discardableResult
    private func place(_ tag: ClueTag, onTile tileIndex: Int, with viewModel: DescriberBoardViewModel) -> ClueMarkResult {
        viewModel.selectTile(tileIndex)
        return viewModel.choose(tag)
    }

    // MARK: - Board

    func testThirtyTwoUntaggedTilesAllOpenAtTheStart() {
        let viewModel = makeViewModel(repository: describingRepository())
        XCTAssertEqual(viewModel.tiles.count, 32)
        XCTAssertTrue(viewModel.tiles.allSatisfy { tile in tile.tag == nil && viewModel.isTileEnabled(tile) })
        XCTAssertEqual(viewModel.tiles[6].accessibilityLabel, "الصورة 7")
        XCTAssertEqual(viewModel.tiles[6].accessibilityValue, "بدون شعار")
    }

    func testTheWordAndTimerShow() {
        let date = MutableDate(startDate)
        let viewModel = makeViewModel(repository: describingRepository(), date: date)
        XCTAssertEqual(viewModel.wordText, "وحيد القرن")
        XCTAssertEqual(viewModel.timerText, "1:00")
    }

    // MARK: - Cube counter

    func testCubeCounterCountsDownAndStopsAtZero() {
        let viewModel = makeViewModel(repository: describingRepository())
        XCTAssertEqual(viewModel.detailCounterText, "10/10")
        place(.detail, onTile: 0, with: viewModel)
        XCTAssertEqual(viewModel.detailCounterText, "9/10")
        for tileIndex in 1..<10 {
            XCTAssertEqual(place(.detail, onTile: tileIndex, with: viewModel), .placed)
        }
        XCTAssertEqual(viewModel.detailCounterText, "0/10")
        XCTAssertEqual(place(.detail, onTile: 10, with: viewModel), .rejected(.limitReached))
        XCTAssertEqual(viewModel.detailCounterText, "0/10")
    }

    // MARK: - Picker

    func testTappingATileOpensThePickerForIt() {
        let viewModel = makeViewModel(repository: describingRepository())
        viewModel.selectTile(6)
        XCTAssertTrue(viewModel.isPickerPresented)
        XCTAssertEqual(viewModel.pickerSubtitle, "الصورة 7 من 32")
        XCTAssertEqual(viewModel.pickerPreview?.id, 6)
    }

    func testATaggedTileDoesNotOpenThePicker() {
        let viewModel = makeViewModel(repository: describingRepository(marks: [ClueMark(tileIndex: 3, tag: .detail)]))
        XCTAssertFalse(viewModel.isTileEnabled(viewModel.tiles[3]))
        viewModel.selectTile(3)
        XCTAssertFalse(viewModel.isPickerPresented)
    }

    func testFreshPickerOffersEveryTag() {
        let viewModel = makeViewModel(repository: describingRepository())
        viewModel.selectTile(0)
        XCTAssertEqual(viewModel.pickerOptions, [
            BadgeOption(tag: .mainIdea, caption: "صورة واحدة", isEnabled: true),
            BadgeOption(tag: .detail, caption: "10/10", isEnabled: true),
            BadgeOption(tag: .secondaryIdea, caption: "اختيارية", isEnabled: true),
        ])
    }

    func testUsedTagsGreyOutLiveAndIndependently() {
        let viewModel = makeViewModel(repository: describingRepository())
        place(.mainIdea, onTile: 0, with: viewModel)
        viewModel.selectTile(1)
        XCTAssertEqual(viewModel.pickerOptions.map(\.isEnabled), [false, true, true])
        XCTAssertEqual(viewModel.pickerOptions.first?.caption, "استُخدمت")
        viewModel.choose(.secondaryIdea)
        viewModel.selectTile(2)
        XCTAssertEqual(viewModel.pickerOptions.map(\.isEnabled), [false, true, false])
        XCTAssertEqual(viewModel.pickerOptions.last?.caption, "استُخدمت")
    }

    func testChoosingAUsedTagIsRefusedAndKeepsThePickerOpen() {
        let repository = describingRepository(marks: [ClueMark(tileIndex: 0, tag: .mainIdea)])
        let viewModel = makeViewModel(repository: repository)
        viewModel.selectTile(4)
        XCTAssertEqual(viewModel.choose(.mainIdea), .rejected(.limitReached))
        XCTAssertTrue(viewModel.isPickerPresented)
        XCTAssertNil(repository.game?.currentRound.mark(onTile: 4))
    }

    func testChoosingTagsTheTileAndClosesThePicker() {
        let repository = describingRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.selectTile(9)
        XCTAssertEqual(viewModel.choose(.secondaryIdea), .placed)
        XCTAssertFalse(viewModel.isPickerPresented)
        XCTAssertEqual(viewModel.tiles[9].tag, .secondaryIdea)
        XCTAssertEqual(viewModel.tiles[9].accessibilityValue, "فكرة فرعية")
    }

    func testCancelClosesWithoutTagging() {
        let repository = describingRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.selectTile(9)
        viewModel.cancelPicker()
        XCTAssertFalse(viewModel.isPickerPresented)
        XCTAssertEqual(repository.game?.currentRound.marks, [])
    }

    func testEveryTileClosesOnceAllTwelveTagsAreUsed() {
        let tags: [ClueTag] = [.mainIdea] + Array(repeating: .detail, count: 10) + [.secondaryIdea]
        let marks = tags.enumerated().map { tileIndex, tag in ClueMark(tileIndex: tileIndex, tag: tag) }
        let viewModel = makeViewModel(repository: describingRepository(marks: marks))
        XCTAssertTrue(viewModel.tiles.allSatisfy { tile in !viewModel.isTileEnabled(tile) })
        viewModel.selectTile(20)
        XCTAssertFalse(viewModel.isPickerPresented)
    }

    func testThePickerClosesWhenTheRoundEndsUnderIt() {
        let repository = describingRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.selectTile(2)
        RoundTimerUseCaseImpl(repository: repository).expireIfDue(now: startDate.addingTimeInterval(60))
        XCTAssertFalse(viewModel.isPickerPresented)
        XCTAssertFalse(viewModel.isTileEnabled(viewModel.tiles[5]))
    }

    // MARK: - End round

    func testEndingTheRoundUsesTheTimeOfTheTap() {
        let repository = describingRepository()
        let date = MutableDate(startDate)
        let viewModel = makeViewModel(repository: repository, date: date)
        date.now = startDate.addingTimeInterval(20)
        XCTAssertTrue(viewModel.canEndRound)
        XCTAssertTrue(viewModel.endRound())
        XCTAssertFalse(viewModel.canEndRound, "nothing left to end while the ended round is on show")
        XCTAssertEqual(repository.game?.currentRound.phase, .ended(.endedByDescriber))
        XCTAssertEqual(repository.game?.currentRound.endedAt, date.now)
        XCTAssertEqual(viewModel.timerText, "0:40", "frozen at the end")
    }

    func testAGuesserCannotTagEvenThroughTheBoard() {
        let repository = describingRepository()
        let viewModel = makeViewModel(repository: repository, viewerId: GameFixtures.playerId(1))
        viewModel.selectTile(0)
        XCTAssertEqual(viewModel.choose(.detail), .rejected(.notDescriber))
        XCTAssertEqual(repository.saveCount, 0)
    }
}
