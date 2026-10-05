import XCTest
@testable import guessGame

final class EnterNameViewModelTests: XCTestCase {
    private func room(playerCount: Int, capacity: Int = 6, code: String = "8701") -> Room {
        Room(
            code: code,
            capacity: capacity,
            players: (0..<playerCount).map { playerIndex in Player(id: "\(playerIndex)", name: "لاعب\(playerIndex)", color: .green, isOwner: playerIndex == 0) }
        )
    }

    // MARK: - Room data

    func testRoomCodeComesFromTheRoom() {
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 1, code: "1234")).roomCode, "1234")
    }

    func testPlayersCountTextIsComputedFromTheRoom() {
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 0)).playersCountText, "0 من 6 لاعبين")
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 3)).playersCountText, "3 من 6 لاعبين")
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 5, capacity: 5)).playersCountText, "5 من 5 لاعبين")
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 2, capacity: 3)).playersCountText, "2 من 3 لاعبين")
    }

    func testRowsFollowThePlayersInOrderWithOwnerCaptionOnlyOnTheOwner() {
        let rows = EnterNameViewModel(room: room(playerCount: 3)).rows
        XCTAssertEqual(rows.map(\.name), ["لاعب0", "لاعب1", "لاعب2"])
        XCTAssertEqual(rows.map { row in row.caption != nil }, [true, false, false])
    }

    func testNoPlayersMeansNoRows() {
        XCTAssertTrue(EnterNameViewModel(room: room(playerCount: 0)).rows.isEmpty)
    }

    // MARK: - Name and submit

    func testDefaultColorIsGreen() {
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 1)).color, .green)
    }

    func testTrimmedNameDropsSurroundingWhitespace() {
        XCTAssertEqual(EnterNameViewModel(room: room(playerCount: 1), name: "  ربى ").trimmedName, "ربى")
    }

    func testCanSubmitNeedsANonBlankName() {
        for blank in ["", "   ", "\n", " \n "] {
            XCTAssertFalse(EnterNameViewModel(room: room(playerCount: 1), name: blank).canSubmit, "\(blank.debugDescription)")
        }
        XCTAssertTrue(EnterNameViewModel(room: room(playerCount: 1), name: "a").canSubmit)
    }

    func testSubmitPassesTheTrimmedNameAndColorOnce() {
        var submissions: [(String, PlayerColor)] = []
        let viewModel = EnterNameViewModel(room: room(playerCount: 1), name: " ربى ", color: .pink) { name, color in submissions.append((name, color)) }
        viewModel.submit()
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(submissions.first?.0, "ربى")
        XCTAssertEqual(submissions.first?.1, .pink)
    }

    func testSubmitWithABlankNameDoesNothing() {
        var didSubmit = false
        let viewModel = EnterNameViewModel(room: room(playerCount: 1), name: "  ") { _, _ in didSubmit = true }
        viewModel.submit()
        XCTAssertFalse(didSubmit)
    }

    func testSubmitUsesTheLatestNameAndColor() {
        var lastSubmission: (String, PlayerColor)?
        let viewModel = EnterNameViewModel(room: room(playerCount: 1)) { name, color in lastSubmission = (name, color) }
        viewModel.name = "سلمان"
        viewModel.color = .teal
        viewModel.submit()
        XCTAssertEqual(lastSubmission?.0, "سلمان")
        XCTAssertEqual(lastSubmission?.1, .teal)
    }
}
