import XCTest
@testable import guessGame

final class EnterNameViewModelTests: XCTestCase {
    private func room(players: Int, capacity: Int = 6, code: String = "8701") -> Room {
        Room(
            code: code,
            capacity: capacity,
            players: (0..<players).map { Player(id: "\($0)", name: "لاعب\($0)", color: .green, isOwner: $0 == 0) }
        )
    }

    // MARK: - Room data

    func testRoomCodeComesFromTheRoom() {
        XCTAssertEqual(EnterNameViewModel(room: room(players: 1, code: "1234")).roomCode, "1234")
    }

    func testPlayersCountTextIsComputedFromTheRoom() {
        XCTAssertEqual(EnterNameViewModel(room: room(players: 0)).playersCountText, "0 من 6 لاعبين")
        XCTAssertEqual(EnterNameViewModel(room: room(players: 3)).playersCountText, "3 من 6 لاعبين")
        XCTAssertEqual(EnterNameViewModel(room: room(players: 5, capacity: 5)).playersCountText, "5 من 5 لاعبين")
        XCTAssertEqual(EnterNameViewModel(room: room(players: 2, capacity: 3)).playersCountText, "2 من 3 لاعبين")
    }

    func testRowsFollowThePlayersInOrderWithOwnerCaptionOnlyOnTheOwner() {
        let rows = EnterNameViewModel(room: room(players: 3)).rows
        XCTAssertEqual(rows.map(\.name), ["لاعب0", "لاعب1", "لاعب2"])
        XCTAssertEqual(rows.map { $0.caption != nil }, [true, false, false])
    }

    func testNoPlayersMeansNoRows() {
        XCTAssertTrue(EnterNameViewModel(room: room(players: 0)).rows.isEmpty)
    }

    // MARK: - Name and submit

    func testDefaultColorIsGreen() {
        XCTAssertEqual(EnterNameViewModel(room: room(players: 1)).color, .green)
    }

    func testTrimmedNameDropsSurroundingWhitespace() {
        XCTAssertEqual(EnterNameViewModel(room: room(players: 1), name: "  ربى ").trimmedName, "ربى")
    }

    func testCanSubmitNeedsANonBlankName() {
        for blank in ["", "   ", "\n", " \n "] {
            XCTAssertFalse(EnterNameViewModel(room: room(players: 1), name: blank).canSubmit, "\(blank.debugDescription)")
        }
        XCTAssertTrue(EnterNameViewModel(room: room(players: 1), name: "a").canSubmit)
    }

    func testSubmitPassesTheTrimmedNameAndColorOnce() {
        var calls: [(String, PlayerColor)] = []
        let viewModel = EnterNameViewModel(room: room(players: 1), name: " ربى ", color: .pink) { calls.append(($0, $1)) }
        viewModel.submit()
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.first?.0, "ربى")
        XCTAssertEqual(calls.first?.1, .pink)
    }

    func testSubmitWithABlankNameDoesNothing() {
        var called = false
        let viewModel = EnterNameViewModel(room: room(players: 1), name: "  ") { _, _ in called = true }
        viewModel.submit()
        XCTAssertFalse(called)
    }

    func testSubmitUsesTheLatestNameAndColor() {
        var received: (String, PlayerColor)?
        let viewModel = EnterNameViewModel(room: room(players: 1)) { received = ($0, $1) }
        viewModel.name = "سلمان"
        viewModel.color = .teal
        viewModel.submit()
        XCTAssertEqual(received?.0, "سلمان")
        XCTAssertEqual(received?.1, .teal)
    }
}
