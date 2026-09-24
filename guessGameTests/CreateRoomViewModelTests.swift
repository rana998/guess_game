import XCTest
@testable import guessGame

final class CreateRoomViewModelTests: XCTestCase {
    func testDefaultsAreSixPlayersSixtySecondsAndGreen() {
        let viewModel = CreateRoomViewModel()
        XCTAssertEqual(viewModel.playerCount, 6)
        XCTAssertEqual(viewModel.roundSeconds, 60)
        XCTAssertEqual(viewModel.avatarColor, .green)
    }

    func testOptionsComeFromTheRoomLimits() {
        let viewModel = CreateRoomViewModel()
        XCTAssertEqual(viewModel.playerCountOptions, [3, 4, 5, 6])
        XCTAssertEqual(viewModel.roundSecondsOptions, [30, 60, 90])
    }

    func testSubmitBuildsTheOwnersRoomAndSession() throws {
        var sessions: [WaitingRoomSession] = []
        let viewModel = CreateRoomViewModel(
            name: "  لاعب  ",
            makeCode: { "1234" },
            makePlayerId: { "owner-id" },
            onCreate: { sessions.append($0) }
        )
        viewModel.avatarColor = .purple
        viewModel.playerCount = 4
        viewModel.roundSeconds = 90
        viewModel.submit()

        XCTAssertEqual(sessions.count, 1)
        let session = try XCTUnwrap(sessions.first)
        XCTAssertEqual(session.role, .owner)
        XCTAssertEqual(session.currentPlayerId, "owner-id")
        XCTAssertEqual(session.room.code, "1234")
        XCTAssertEqual(session.room.capacity, 4)
        XCTAssertEqual(session.room.roundSeconds, 90)
        XCTAssertEqual(session.room.players, [
            Player(id: "owner-id", name: "لاعب", color: .purple, isOwner: true, isReady: true),
        ])
    }

    func testBlankNameDoesNotSubmit() {
        var called = false
        let viewModel = CreateRoomViewModel(name: "   ", onCreate: { _ in called = true })
        XCTAssertFalse(viewModel.canSubmit)
        viewModel.submit()
        XCTAssertFalse(called)
    }
}
