import XCTest
@testable import guessGame

final class WordCardViewModelTests: XCTestCase {
    private let describerId = GameFixtures.playerId(0)

    func testShowsTheWordAndItsDifficultyChip() {
        let repository = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn, difficulty: .medium, word: "وحيد القرن", endsAt: nil))
        let viewModel = WordCardViewModel(
            useCases: GameFixtures.makeUseCases(repository: repository),
            viewerId: describerId,
            clock: GameClock(currentDate: { GameFixtures.startDate })
        )
        XCTAssertEqual(viewModel.wordText, "وحيد القرن")
        XCTAssertEqual(viewModel.chipText, "متوسط +2")
    }

    func testChecklistNamesEachTagWithItsLimit() {
        let viewModel = WordCardViewModel(
            useCases: GameFixtures.makeUseCases(repository: GameRepositoryFake()),
            viewerId: describerId,
            clock: GameClock(currentDate: { GameFixtures.startDate })
        )
        XCTAssertEqual(viewModel.ruleText(for: .mainIdea), "الفكرة الرئيسية (صورة واحدة)")
        XCTAssertEqual(viewModel.ruleText(for: .detail), "تفصيل إضافي للفكرة الرئيسية (10 مكعبات)")
        XCTAssertEqual(viewModel.ruleText(for: .secondaryIdea), "فكرة فرعية (واحدة، اختيارية)")
    }

    func testStartingUsesTheTimeOfTheTapNotAnEarlierTick() {
        let repository = GameRepositoryFake(game: GameFixtures.game(phase: .wordDrawn, endsAt: nil, roundSeconds: 60))
        let date = MutableDate(GameFixtures.startDate)
        let clock = GameClock(currentDate: { date.now })
        let viewModel = WordCardViewModel(useCases: GameFixtures.makeUseCases(repository: repository), viewerId: describerId, clock: clock)
        // The describer reads the word for five minutes; nothing ticks meanwhile.
        date.now = GameFixtures.startDate.addingTimeInterval(300)
        XCTAssertTrue(viewModel.startDescribing())
        XCTAssertEqual(repository.game?.currentRound.phase, .describing)
        XCTAssertEqual(repository.game?.currentRound.endsAt, date.now.addingTimeInterval(60))
    }
}
