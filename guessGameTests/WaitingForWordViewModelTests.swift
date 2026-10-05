import XCTest
@testable import guessGame

final class WaitingForWordViewModelTests: XCTestCase {
    /// Six players; player 2 describes this round (turn order is room order).
    private func makeViewModel(viewerIndex: Int, playerCount: Int = 6, roundIndex: Int = 2) -> WaitingForWordViewModel {
        let game = GameFixtures.game(playerCount: playerCount, roundIndex: roundIndex, phase: .choosingWord, difficulty: nil, word: nil, endsAt: nil)
        return WaitingForWordViewModel(
            useCases: GameFixtures.makeUseCases(repository: GameRepositoryFake(game: game)),
            viewerId: GameFixtures.playerId(viewerIndex),
            clock: GameClock(currentDate: { GameFixtures.startDate })
        )
    }

    func testNamesTheDescriber() {
        let viewModel = makeViewModel(viewerIndex: 4)
        XCTAssertEqual(viewModel.describerAvatar?.id, "player-2")
        XCTAssertEqual(viewModel.describerPillText, "\u{200F}لاعب2 تختار الكلمة")
        XCTAssertEqual(viewModel.message, "لم يبدأ العدّ بعد. سيبدأ المؤقت لحظة ضغط لاعب2 على \"ابدأ الوصف\"")
    }

    func testDescriberPillStaysRightToLeftForALatinName() {
        XCTAssertEqual(Strings.WaitingForWord.describerChoosing(name: "Sara"), "\u{200F}Sara تختار الكلمة")
    }

    func testGuessersAreEveryoneButTheDescriberInRoomOrder() {
        XCTAssertEqual(makeViewModel(viewerIndex: 4).guesserAvatars.map(\.id), ["player-0", "player-1", "player-3", "player-4", "player-5"])
    }

    func testGuesserCount() {
        XCTAssertEqual(makeViewModel(viewerIndex: 4).guessersCountText, "5 مخمنين جاهزين")
        XCTAssertEqual(makeViewModel(viewerIndex: 1, playerCount: 3, roundIndex: 0).guessersCountText, "مخمنان جاهزان")
    }

    func testTurnBadgeCountsTheRoundsUntilTheViewerDescribes() {
        XCTAssertEqual(makeViewModel(viewerIndex: 3).turnBadgeText, "دورك في الوصف في الجولة التالية")
        XCTAssertEqual(makeViewModel(viewerIndex: 4).turnBadgeText, "دورك في الوصف بعد جولتين")
        XCTAssertEqual(makeViewModel(viewerIndex: 5).turnBadgeText, "دورك في الوصف بعد 3 جولات")
    }

    func testNoTurnBadgeOnceTheViewerHasDescribed() {
        XCTAssertNil(makeViewModel(viewerIndex: 0).turnBadgeText)
        XCTAssertNil(makeViewModel(viewerIndex: 1).turnBadgeText)
    }
}
