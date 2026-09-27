import XCTest
@testable import guessGame

final class WaitingForWordViewModelTests: XCTestCase {
    /// Six players; player 2 describes this round (turn order is room order).
    private func makeViewModel(viewer: Int, playerCount: Int = 6, roundIndex: Int = 2) -> WaitingForWordViewModel {
        let game = GameFixtures.game(playerCount: playerCount, roundIndex: roundIndex, phase: .choosingWord, difficulty: nil, word: nil, endsAt: nil)
        return WaitingForWordViewModel(
            useCases: GameFixtures.makeUseCases(repository: GameRepositoryFake(game: game)),
            viewerId: GameFixtures.playerId(viewer),
            clock: GameClock(currentDate: { GameFixtures.startDate })
        )
    }

    func testNamesTheDescriber() {
        let viewModel = makeViewModel(viewer: 4)
        XCTAssertEqual(viewModel.describerAvatar?.id, "player-2")
        XCTAssertEqual(viewModel.describerPillText, "بانتظار كلمة لاعب2")
        XCTAssertEqual(viewModel.message, "لم يبدأ العدّ بعد. سيبدأ المؤقت لحظة ضغط لاعب2 على \"ابدأ الوصف\"")
    }

    func testGuessersAreEveryoneButTheDescriberInRoomOrder() {
        XCTAssertEqual(makeViewModel(viewer: 4).guesserAvatars.map(\.id), ["player-0", "player-1", "player-3", "player-4", "player-5"])
    }

    func testGuesserCount() {
        XCTAssertEqual(makeViewModel(viewer: 4).guessersCountText, "5 مخمنين جاهزين")
        XCTAssertEqual(makeViewModel(viewer: 1, playerCount: 3, roundIndex: 0).guessersCountText, "مخمنان جاهزان")
    }

    func testTurnBadgeCountsTheRoundsUntilTheViewerDescribes() {
        XCTAssertEqual(makeViewModel(viewer: 3).turnBadgeText, "دورك في الوصف في الجولة التالية")
        XCTAssertEqual(makeViewModel(viewer: 4).turnBadgeText, "دورك في الوصف بعد جولتين")
        XCTAssertEqual(makeViewModel(viewer: 5).turnBadgeText, "دورك في الوصف بعد 3 جولات")
    }

    func testNoTurnBadgeOnceTheViewerHasDescribed() {
        XCTAssertNil(makeViewModel(viewer: 0).turnBadgeText)
        XCTAssertNil(makeViewModel(viewer: 1).turnBadgeText)
    }
}
