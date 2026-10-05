import XCTest
@testable import guessGame

final class WaitingRoomViewModelTests: XCTestCase {
    /// Players "لاعب0"… with ids "0"…; player 0 is the owner (always ready).
    /// `readyIndices` lists which of the others are ready.
    private func room(playerCount: Int, capacity: Int = 6, readyIndices: Set<Int> = [], code: String = "1234") -> Room {
        Room(
            code: code,
            capacity: capacity,
            players: (0..<playerCount).map { playerIndex in
                Player(id: "\(playerIndex)", name: "لاعب\(playerIndex)", color: .green, isOwner: playerIndex == 0, isReady: playerIndex == 0 || readyIndices.contains(playerIndex))
            }
        )
    }

    private final class Spy {
        var copiedCodes: [String] = []
        var startedRooms: [Room] = []
        var leaveCount = 0
    }

    private func makeViewModel(_ room: Room, viewerId: String = "0", role: RoomRole = .owner, spy: Spy = Spy()) -> WaitingRoomViewModel {
        WaitingRoomViewModel(
            session: WaitingRoomSession(room: room, role: role, currentPlayerId: viewerId),
            copyToPasteboard: { copiedCode in spy.copiedCodes.append(copiedCode) },
            onStartGame: { startedRoom in spy.startedRooms.append(startedRoom) },
            onLeave: { spy.leaveCount += 1 }
        )
    }

    // MARK: - Ready count

    func testReadyCountTextForTheOwnerAlone() {
        XCTAssertEqual(makeViewModel(room(playerCount: 1)).readyCountText, "1 من 1 جاهزين")
    }

    func testReadyCountTextCountsPresentPlayersNotCapacity() {
        XCTAssertEqual(makeViewModel(room(playerCount: 6, readyIndices: [1, 3, 5])).readyCountText, "4 من 6 جاهزين")
        XCTAssertEqual(makeViewModel(room(playerCount: 2, capacity: 6)).readyCountText, "1 من 2 جاهزين")
    }

    func testRemovingAReadyPlayerDropsBothCounts() {
        let viewModel = makeViewModel(room(playerCount: 6, readyIndices: [1, 3, 5]))
        viewModel.removePlayer(id: "1")
        XCTAssertEqual(viewModel.readyCountText, "3 من 5 جاهزين")
    }

    // MARK: - Slots

    func testSlotCountEqualsCapacity() {
        for capacity in [3, 4, 6] {
            XCTAssertEqual(makeViewModel(room(playerCount: 2, capacity: capacity)).slots.count, capacity)
        }
    }

    func testPlayersComeFirstInOrderThenEmptySeats() {
        let slots = makeViewModel(room(playerCount: 2, capacity: 4)).slots
        XCTAssertEqual(slots.map(\.id), ["0", "1", "empty-2", "empty-3"])
        XCTAssertEqual(slots.last, .empty(index: 3))
    }

    // MARK: - Ready toggle

    func testToggleReadyFlipsOnlyTheParticipantsOwnFlag() {
        let viewModel = makeViewModel(room(playerCount: 4, readyIndices: [1]), viewerId: "2", role: .participant)
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.room.players.map(\.isReady), [true, true, true, false])
        XCTAssertTrue(viewModel.isCurrentPlayerReady)
        XCTAssertEqual(viewModel.readyToggleTitle, "إلغاء الجاهزية")
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.room.players.map(\.isReady), [true, true, false, false])
        XCTAssertEqual(viewModel.readyToggleTitle, "جاهز الآن")
    }

    func testOwnerToggleDoesNothing() {
        let viewModel = makeViewModel(room(playerCount: 3))
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.room.players.map(\.isReady), [true, false, false])
    }

    func testToggleReadyDoesNothingWhileStarting() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 3, readyIndices: [1, 2]), viewerId: "2", role: .participant, spy: spy)
        viewModel.toggleReady()
        viewModel.toggleReady() // ready again → auto-start
        XCTAssertTrue(viewModel.isStarting)
        viewModel.toggleReady()
        XCTAssertTrue(viewModel.isCurrentPlayerReady)
    }

    // MARK: - Remove

    func testOwnerRemovesAnotherParticipant() {
        let viewModel = makeViewModel(room(playerCount: 4))
        viewModel.removePlayer(id: "2")
        XCTAssertEqual(viewModel.room.players.map(\.id), ["0", "1", "3"])
    }

    func testOwnerCannotRemoveThemselves() {
        let viewModel = makeViewModel(room(playerCount: 4))
        viewModel.removePlayer(id: "0")
        XCTAssertEqual(viewModel.room.players.count, 4)
    }

    func testTheOwnerCannotBeRemovedEvenIfViewerIdDiffers() {
        // An owner-role viewer whose own id isn't the owner's must still not remove the owner.
        let viewModel = makeViewModel(room(playerCount: 4), viewerId: "1", role: .owner)
        viewModel.removePlayer(id: "0")
        XCTAssertEqual(viewModel.room.players.count, 4)
    }

    func testParticipantCannotRemoveAnyone() {
        let viewModel = makeViewModel(room(playerCount: 4), viewerId: "1", role: .participant)
        viewModel.removePlayer(id: "2")
        XCTAssertEqual(viewModel.room.players.count, 4)
    }

    func testRemovingAnUnknownIdDoesNothing() {
        let viewModel = makeViewModel(room(playerCount: 4))
        viewModel.removePlayer(id: "nobody")
        XCTAssertEqual(viewModel.room.players.count, 4)
    }

    func testRemoveDoesNothingWhileStarting() {
        let viewModel = makeViewModel(room(playerCount: 4))
        viewModel.startGame()
        viewModel.removePlayer(id: "2")
        XCTAssertEqual(viewModel.room.players.count, 4)
    }

    // MARK: - Copy

    func testCopyPassesTheExactCodeAndBumpsTheToken() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 1, code: "0042"), spy: spy)
        viewModel.copyRoomCode()
        XCTAssertEqual(spy.copiedCodes, ["0042"])
        XCTAssertEqual(viewModel.copyConfirmationToken, 1)
        XCTAssertTrue(viewModel.isShowingCopyConfirmation)
        viewModel.copyRoomCode()
        XCTAssertEqual(viewModel.copyConfirmationToken, 2)
    }

    func testClearCopyConfirmationIgnoresAStaleToken() {
        let viewModel = makeViewModel(room(playerCount: 1))
        viewModel.copyRoomCode()
        viewModel.copyRoomCode()
        viewModel.clearCopyConfirmation(token: 1)
        XCTAssertTrue(viewModel.isShowingCopyConfirmation)
        viewModel.clearCopyConfirmation(token: 2)
        XCTAssertFalse(viewModel.isShowingCopyConfirmation)
    }

    // MARK: - Round length

    func testOwnerPicksAnOfferedRoundLength() {
        let viewModel = makeViewModel(room(playerCount: 3))
        for seconds in [30, 60, 90] {
            viewModel.setRoundSeconds(seconds)
            XCTAssertEqual(viewModel.roundSeconds, seconds)
        }
        viewModel.setRoundSeconds(45)
        XCTAssertEqual(viewModel.roundSeconds, 90)
    }

    func testParticipantCannotChangeTheRoundLength() {
        let viewModel = makeViewModel(room(playerCount: 3), viewerId: "1", role: .participant)
        viewModel.setRoundSeconds(30)
        XCTAssertEqual(viewModel.roundSeconds, 60)
    }

    func testRoundLengthIsLockedWhileStarting() {
        let viewModel = makeViewModel(room(playerCount: 3))
        viewModel.startGame()
        viewModel.setRoundSeconds(30)
        XCTAssertEqual(viewModel.roundSeconds, 60)
    }

    // MARK: - canStart

    func testCanStartNeedsThreePlayersButNotEveryoneReady() {
        XCTAssertFalse(makeViewModel(room(playerCount: 2)).canStart)
        XCTAssertTrue(makeViewModel(room(playerCount: 3)).canStart)
    }

    func testParticipantCanNeverStart() {
        XCTAssertFalse(makeViewModel(room(playerCount: 3), viewerId: "1", role: .participant).canStart)
    }

    func testCannotStartAgainAfterStarting() {
        let viewModel = makeViewModel(room(playerCount: 3))
        viewModel.startGame()
        XCTAssertFalse(viewModel.canStart)
    }

    // MARK: - startGame

    func testStartBelowThreePlayersDoesNothing() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 2), spy: spy)
        viewModel.startGame()
        XCTAssertTrue(spy.startedRooms.isEmpty)
        XCTAssertEqual(viewModel.phase, .waiting)
    }

    func testStartMovesToStartingAndReportsTheRoomOnce() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 3), spy: spy)
        viewModel.setRoundSeconds(90)
        viewModel.startGame()
        XCTAssertEqual(viewModel.phase, .starting)
        XCTAssertEqual(spy.startedRooms, [viewModel.room])
        XCTAssertEqual(spy.startedRooms.first?.roundSeconds, 90)
        viewModel.startGame()
        XCTAssertEqual(spy.startedRooms.count, 1)
        XCTAssertEqual(viewModel.startButtonTitle, "جارٍ بدء اللعبة…")
    }

    func testStartButtonTitleBeforeStarting() {
        XCTAssertEqual(makeViewModel(room(playerCount: 3)).startButtonTitle, "ابدأ اللعبة")
    }

    func testParticipantCaptionSwitchesWhenTheGameAutoStarts() {
        let viewModel = makeViewModel(room(playerCount: 3, readyIndices: [1]), viewerId: "2", role: .participant)
        XCTAssertEqual(viewModel.participantCaption, "تبدأ اللعبة تلقائيًا عندما يجهز الجميع")
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.participantCaption, "جارٍ بدء اللعبة…")
    }

    // MARK: - Auto-start

    func testLastPlayerGettingReadyStartsTheGameOnce() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 3, readyIndices: [1]), viewerId: "2", role: .participant, spy: spy)
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.phase, .starting)
        XCTAssertEqual(spy.startedRooms.count, 1)
    }

    func testEveryoneReadyWithTwoPlayersDoesNotStart() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 2), viewerId: "1", role: .participant, spy: spy)
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.phase, .waiting)
        XCTAssertTrue(spy.startedRooms.isEmpty)
    }

    func testRemovingTheLastUnreadyPlayerStartsTheGameOnce() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 4, readyIndices: [1, 2]), spy: spy)
        viewModel.removePlayer(id: "3")
        XCTAssertEqual(viewModel.phase, .starting)
        XCTAssertEqual(spy.startedRooms.count, 1)
        XCTAssertEqual(spy.startedRooms.first?.players.count, 3)
    }

    func testRemovalLeavingTwoReadyPlayersDoesNotStart() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 3, readyIndices: [1]), spy: spy)
        viewModel.removePlayer(id: "2")
        XCTAssertEqual(viewModel.phase, .waiting)
        XCTAssertTrue(spy.startedRooms.isEmpty)
    }

    func testTogglingBackToNotReadyDoesNotStart() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 4, readyIndices: [1, 2]), viewerId: "2", role: .participant, spy: spy)
        viewModel.toggleReady()
        XCTAssertEqual(viewModel.phase, .waiting)
        XCTAssertTrue(spy.startedRooms.isEmpty)
    }

    func testOpeningAnAllReadyRoomDoesNotStart() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 3, readyIndices: [1, 2]), viewerId: "1", role: .participant, spy: spy)
        XCTAssertEqual(viewModel.phase, .waiting)
        XCTAssertTrue(spy.startedRooms.isEmpty)
    }

    func testLaterIntentsDoNotStartAgainAfterAnAutoStart() {
        let spy = Spy()
        let viewModel = makeViewModel(room(playerCount: 4, readyIndices: [1, 2]), spy: spy)
        viewModel.removePlayer(id: "3")
        viewModel.startGame()
        viewModel.removePlayer(id: "2")
        viewModel.toggleReady()
        XCTAssertEqual(spy.startedRooms.count, 1)
    }

    // MARK: - Leave

    func testLeaveRoomCallsOnLeaveOnce() {
        let spy = Spy()
        makeViewModel(room(playerCount: 3), spy: spy).leaveRoom()
        XCTAssertEqual(spy.leaveCount, 1)
    }
}
