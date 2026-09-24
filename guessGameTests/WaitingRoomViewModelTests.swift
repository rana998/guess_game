import XCTest
@testable import guessGame

final class WaitingRoomViewModelTests: XCTestCase {
    /// Players "لاعب0"… with ids "0"…; player 0 is the owner (always ready).
    /// `ready` lists which of the others are ready.
    private func room(players: Int, capacity: Int = 6, ready: Set<Int> = [], code: String = "1234") -> Room {
        Room(
            code: code,
            capacity: capacity,
            players: (0..<players).map {
                Player(id: "\($0)", name: "لاعب\($0)", color: .green, isOwner: $0 == 0, isReady: $0 == 0 || ready.contains($0))
            }
        )
    }

    private final class Spy {
        var copied: [String] = []
        var started: [Room] = []
        var leaves = 0
    }

    private func viewModel(_ room: Room, viewer: String = "0", role: RoomRole = .owner, spy: Spy = Spy()) -> WaitingRoomViewModel {
        WaitingRoomViewModel(
            session: WaitingRoomSession(room: room, role: role, currentPlayerId: viewer),
            copyToPasteboard: { spy.copied.append($0) },
            onStartGame: { spy.started.append($0) },
            onLeave: { spy.leaves += 1 }
        )
    }

    // MARK: - Ready count

    func testReadyCountTextForTheOwnerAlone() {
        XCTAssertEqual(viewModel(room(players: 1)).readyCountText, "1 من 1 جاهزين")
    }

    func testReadyCountTextCountsPresentPlayersNotCapacity() {
        XCTAssertEqual(viewModel(room(players: 6, ready: [1, 3, 5])).readyCountText, "4 من 6 جاهزين")
        XCTAssertEqual(viewModel(room(players: 2, capacity: 6)).readyCountText, "1 من 2 جاهزين")
    }

    func testRemovingAReadyPlayerDropsBothCounts() {
        let model = viewModel(room(players: 6, ready: [1, 3, 5]))
        model.removePlayer(id: "1")
        XCTAssertEqual(model.readyCountText, "3 من 5 جاهزين")
    }

    // MARK: - Slots

    func testSlotCountEqualsCapacity() {
        for capacity in [3, 4, 6] {
            XCTAssertEqual(viewModel(room(players: 2, capacity: capacity)).slots.count, capacity)
        }
    }

    func testPlayersComeFirstInOrderThenEmptySeats() {
        let slots = viewModel(room(players: 2, capacity: 4)).slots
        XCTAssertEqual(slots.map(\.id), ["0", "1", "empty-2", "empty-3"])
        XCTAssertEqual(slots.last, .empty(index: 3))
    }

    // MARK: - Ready toggle

    func testToggleReadyFlipsOnlyTheParticipantsOwnFlag() {
        let model = viewModel(room(players: 4, ready: [1]), viewer: "2", role: .participant)
        model.toggleReady()
        XCTAssertEqual(model.room.players.map(\.isReady), [true, true, true, false])
        XCTAssertTrue(model.isCurrentPlayerReady)
        XCTAssertEqual(model.readyToggleTitle, "إلغاء الجاهزية")
        model.toggleReady()
        XCTAssertEqual(model.room.players.map(\.isReady), [true, true, false, false])
        XCTAssertEqual(model.readyToggleTitle, "جاهز الآن")
    }

    func testOwnerToggleDoesNothing() {
        let model = viewModel(room(players: 3))
        model.toggleReady()
        XCTAssertEqual(model.room.players.map(\.isReady), [true, false, false])
    }

    func testToggleReadyDoesNothingWhileStarting() {
        let spy = Spy()
        let model = viewModel(room(players: 3, ready: [1, 2]), viewer: "2", role: .participant, spy: spy)
        model.toggleReady()
        model.toggleReady() // ready again → auto-start
        XCTAssertTrue(model.isStarting)
        model.toggleReady()
        XCTAssertTrue(model.isCurrentPlayerReady)
    }

    // MARK: - Remove

    func testOwnerRemovesAnotherParticipant() {
        let model = viewModel(room(players: 4))
        model.removePlayer(id: "2")
        XCTAssertEqual(model.room.players.map(\.id), ["0", "1", "3"])
    }

    func testOwnerCannotRemoveThemselves() {
        let model = viewModel(room(players: 4))
        model.removePlayer(id: "0")
        XCTAssertEqual(model.room.players.count, 4)
    }

    func testTheOwnerCannotBeRemovedEvenIfViewerIdDiffers() {
        // An owner-role viewer whose own id isn't the owner's must still not remove the owner.
        let model = viewModel(room(players: 4), viewer: "1", role: .owner)
        model.removePlayer(id: "0")
        XCTAssertEqual(model.room.players.count, 4)
    }

    func testParticipantCannotRemoveAnyone() {
        let model = viewModel(room(players: 4), viewer: "1", role: .participant)
        model.removePlayer(id: "2")
        XCTAssertEqual(model.room.players.count, 4)
    }

    func testRemovingAnUnknownIdDoesNothing() {
        let model = viewModel(room(players: 4))
        model.removePlayer(id: "nobody")
        XCTAssertEqual(model.room.players.count, 4)
    }

    func testRemoveDoesNothingWhileStarting() {
        let model = viewModel(room(players: 4))
        model.startGame()
        model.removePlayer(id: "2")
        XCTAssertEqual(model.room.players.count, 4)
    }

    // MARK: - Copy

    func testCopyPassesTheExactCodeAndBumpsTheToken() {
        let spy = Spy()
        let model = viewModel(room(players: 1, code: "0042"), spy: spy)
        model.copyRoomCode()
        XCTAssertEqual(spy.copied, ["0042"])
        XCTAssertEqual(model.copyConfirmationToken, 1)
        XCTAssertTrue(model.isShowingCopyConfirmation)
        model.copyRoomCode()
        XCTAssertEqual(model.copyConfirmationToken, 2)
    }

    func testClearCopyConfirmationIgnoresAStaleToken() {
        let model = viewModel(room(players: 1))
        model.copyRoomCode()
        model.copyRoomCode()
        model.clearCopyConfirmation(token: 1)
        XCTAssertTrue(model.isShowingCopyConfirmation)
        model.clearCopyConfirmation(token: 2)
        XCTAssertFalse(model.isShowingCopyConfirmation)
    }

    // MARK: - Round length

    func testOwnerPicksAnOfferedRoundLength() {
        let model = viewModel(room(players: 3))
        for seconds in [30, 60, 90] {
            model.setRoundSeconds(seconds)
            XCTAssertEqual(model.roundSeconds, seconds)
        }
        model.setRoundSeconds(45)
        XCTAssertEqual(model.roundSeconds, 90)
    }

    func testParticipantCannotChangeTheRoundLength() {
        let model = viewModel(room(players: 3), viewer: "1", role: .participant)
        model.setRoundSeconds(30)
        XCTAssertEqual(model.roundSeconds, 60)
    }

    func testRoundLengthIsLockedWhileStarting() {
        let model = viewModel(room(players: 3))
        model.startGame()
        model.setRoundSeconds(30)
        XCTAssertEqual(model.roundSeconds, 60)
    }

    // MARK: - canStart

    func testCanStartNeedsThreePlayersButNotEveryoneReady() {
        XCTAssertFalse(viewModel(room(players: 2)).canStart)
        XCTAssertTrue(viewModel(room(players: 3)).canStart)
    }

    func testParticipantCanNeverStart() {
        XCTAssertFalse(viewModel(room(players: 3), viewer: "1", role: .participant).canStart)
    }

    func testCannotStartAgainAfterStarting() {
        let model = viewModel(room(players: 3))
        model.startGame()
        XCTAssertFalse(model.canStart)
    }

    // MARK: - startGame

    func testStartBelowThreePlayersDoesNothing() {
        let spy = Spy()
        let model = viewModel(room(players: 2), spy: spy)
        model.startGame()
        XCTAssertTrue(spy.started.isEmpty)
        XCTAssertEqual(model.phase, .waiting)
    }

    func testStartMovesToStartingAndReportsTheRoomOnce() {
        let spy = Spy()
        let model = viewModel(room(players: 3), spy: spy)
        model.setRoundSeconds(90)
        model.startGame()
        XCTAssertEqual(model.phase, .starting)
        XCTAssertEqual(spy.started, [model.room])
        XCTAssertEqual(spy.started.first?.roundSeconds, 90)
        model.startGame()
        XCTAssertEqual(spy.started.count, 1)
        XCTAssertEqual(model.startButtonTitle, "جارٍ بدء اللعبة…")
    }

    func testStartButtonTitleBeforeStarting() {
        XCTAssertEqual(viewModel(room(players: 3)).startButtonTitle, "ابدأ اللعبة")
    }

    func testParticipantCaptionSwitchesWhenTheGameAutoStarts() {
        let model = viewModel(room(players: 3, ready: [1]), viewer: "2", role: .participant)
        XCTAssertEqual(model.participantCaption, "تبدأ اللعبة تلقائيًا عندما يجهز الجميع")
        model.toggleReady()
        XCTAssertEqual(model.participantCaption, "جارٍ بدء اللعبة…")
    }

    // MARK: - Auto-start

    func testLastPlayerGettingReadyStartsTheGameOnce() {
        let spy = Spy()
        let model = viewModel(room(players: 3, ready: [1]), viewer: "2", role: .participant, spy: spy)
        model.toggleReady()
        XCTAssertEqual(model.phase, .starting)
        XCTAssertEqual(spy.started.count, 1)
    }

    func testEveryoneReadyWithTwoPlayersDoesNotStart() {
        let spy = Spy()
        let model = viewModel(room(players: 2), viewer: "1", role: .participant, spy: spy)
        model.toggleReady()
        XCTAssertEqual(model.phase, .waiting)
        XCTAssertTrue(spy.started.isEmpty)
    }

    func testRemovingTheLastUnreadyPlayerStartsTheGameOnce() {
        let spy = Spy()
        let model = viewModel(room(players: 4, ready: [1, 2]), spy: spy)
        model.removePlayer(id: "3")
        XCTAssertEqual(model.phase, .starting)
        XCTAssertEqual(spy.started.count, 1)
        XCTAssertEqual(spy.started.first?.players.count, 3)
    }

    func testRemovalLeavingTwoReadyPlayersDoesNotStart() {
        let spy = Spy()
        let model = viewModel(room(players: 3, ready: [1]), spy: spy)
        model.removePlayer(id: "2")
        XCTAssertEqual(model.phase, .waiting)
        XCTAssertTrue(spy.started.isEmpty)
    }

    func testTogglingBackToNotReadyDoesNotStart() {
        let spy = Spy()
        let model = viewModel(room(players: 4, ready: [1, 2]), viewer: "2", role: .participant, spy: spy)
        model.toggleReady()
        XCTAssertEqual(model.phase, .waiting)
        XCTAssertTrue(spy.started.isEmpty)
    }

    func testOpeningAnAllReadyRoomDoesNotStart() {
        let spy = Spy()
        let model = viewModel(room(players: 3, ready: [1, 2]), viewer: "1", role: .participant, spy: spy)
        XCTAssertEqual(model.phase, .waiting)
        XCTAssertTrue(spy.started.isEmpty)
    }

    func testLaterIntentsDoNotStartAgainAfterAnAutoStart() {
        let spy = Spy()
        let model = viewModel(room(players: 4, ready: [1, 2]), spy: spy)
        model.removePlayer(id: "3")
        model.startGame()
        model.removePlayer(id: "2")
        model.toggleReady()
        XCTAssertEqual(spy.started.count, 1)
    }

    // MARK: - Leave

    func testLeaveRoomCallsOnLeaveOnce() {
        let spy = Spy()
        viewModel(room(players: 3), spy: spy).leaveRoom()
        XCTAssertEqual(spy.leaves, 1)
    }
}
