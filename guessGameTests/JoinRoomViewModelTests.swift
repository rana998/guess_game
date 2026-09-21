import XCTest
@testable import guessGame

final class JoinRoomViewModelTests: XCTestCase {
    private func type(_ digits: [Int], into viewModel: JoinRoomViewModel) {
        digits.forEach { viewModel.appendDigit($0) }
    }

    // MARK: - Entry

    func testAppendsUpToCapacityAndIgnoresFifthDigit() {
        let viewModel = JoinRoomViewModel()
        type([8, 7, 0, 2, 5], into: viewModel)
        XCTAssertEqual(viewModel.code, "8702")
    }

    func testIgnoresDigitsOutsideZeroToNine() {
        let viewModel = JoinRoomViewModel()
        viewModel.appendDigit(10)
        viewModel.appendDigit(-1)
        XCTAssertEqual(viewModel.code, "")
    }

    func testDeleteRemovesLastDigit() {
        let viewModel = JoinRoomViewModel(code: "87")
        viewModel.deleteLast()
        XCTAssertEqual(viewModel.code, "8")
    }

    func testDeleteOnEmptyCodeIsNoOp() {
        let viewModel = JoinRoomViewModel()
        viewModel.deleteLast()
        XCTAssertEqual(viewModel.code, "")
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testInitSanitisesCodeToAsciiDigitsMax4() {
        XCTAssertEqual(JoinRoomViewModel(code: "8a7-0 2 9").code, "8702")
        XCTAssertEqual(JoinRoomViewModel(code: "٨٧٠٢").code, "")
    }

    // MARK: - Errors

    func testEditingLeavesInvalidCodeState() {
        let typed = JoinRoomViewModel(code: "8702", state: .invalidCode)
        typed.appendDigit(1)
        XCTAssertEqual(typed.state, .idle)

        let deleted = JoinRoomViewModel(code: "8702", state: .invalidCode)
        deleted.deleteLast()
        XCTAssertEqual(deleted.state, .idle)
        XCTAssertEqual(deleted.code, "870")
    }

    func testDigitOnFullErroringCodeClearsErrorButKeepsCode() {
        let viewModel = JoinRoomViewModel(code: "8702", state: .invalidCode)
        viewModel.appendDigit(5)
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.code, "8702")
    }

    // MARK: - Confirm

    func testConfirmWithFewerThanFourDigitsIsInvalidCode() {
        let viewModel = JoinRoomViewModel(code: "870")
        viewModel.confirm()
        XCTAssertEqual(viewModel.state, .invalidCode)
        XCTAssertEqual(viewModel.code, "870")
    }

    func testConfirmWithFourDigitsUsesResolverOutcome() {
        let joinedRoom = Room(code: "8704", capacity: 6, players: [])
        let cases: [(outcome: JoinOutcome, state: JoinRoomState)] = [
            (.joined(joinedRoom), .idle),
            (.invalidCode, .invalidCode),
            (.roomFull(capacity: 6), .roomFull(capacity: 6)),
        ]
        for testCase in cases {
            var received: String?
            let viewModel = JoinRoomViewModel(code: "8704", resolve: { code in
                received = code
                return testCase.outcome
            })
            viewModel.confirm()
            XCTAssertEqual(received, "8704")
            XCTAssertEqual(viewModel.state, testCase.state)
        }
    }

    func testJoinedRoomIsHandedToOnJoinedOnce() {
        let room = Room(code: "8701", capacity: 6, players: [Player(id: "1", name: "نهى", color: .green, isOwner: true)])
        var joined: [Room] = []
        let viewModel = JoinRoomViewModel(code: "8701", resolve: { _ in .joined(room) }, onJoined: { joined.append($0) })
        viewModel.confirm()
        XCTAssertEqual(joined, [room])
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testOnJoinedFiresOnEveryAcceptedConfirm() {
        var count = 0
        let viewModel = JoinRoomViewModel(code: "8701", resolve: { _ in .joined(Room(code: "8701", capacity: 6, players: [])) }, onJoined: { _ in count += 1 })
        viewModel.confirm()
        viewModel.confirm()
        XCTAssertEqual(count, 2)
    }

    func testRejectedOutcomesDoNotCallOnJoined() {
        for outcome in [JoinOutcome.invalidCode, .roomFull(capacity: 6)] {
            var called = false
            let viewModel = JoinRoomViewModel(code: "8704", resolve: { _ in outcome }, onJoined: { _ in called = true })
            viewModel.confirm()
            XCTAssertFalse(called)
        }
    }

    func testIncompleteCodeCallsNeitherResolverNorOnJoined() {
        var resolved = false
        var joined = false
        let viewModel = JoinRoomViewModel(
            code: "870",
            resolve: { _ in resolved = true; return .joined(Room(code: "870", capacity: 6, players: [])) },
            onJoined: { _ in joined = true }
        )
        viewModel.confirm()
        XCTAssertFalse(resolved)
        XCTAssertFalse(joined)
        XCTAssertEqual(viewModel.state, .invalidCode)
    }

    func testDefaultResolverAlwaysInvalidCode() {
        let viewModel = JoinRoomViewModel(code: "1234")
        viewModel.confirm()
        XCTAssertEqual(viewModel.state, .invalidCode)
    }

    func testConfirmInRoomFullIsNoOp() {
        var joined = false
        let viewModel = JoinRoomViewModel(
            code: "8704",
            state: .roomFull(capacity: 6),
            resolve: { _ in .joined(Room(code: "8704", capacity: 6, players: [])) },
            onJoined: { _ in joined = true }
        )
        viewModel.confirm()
        XCTAssertEqual(viewModel.state, .roomFull(capacity: 6))
        XCTAssertFalse(joined)
    }

    func testRetryClearsCodeAndReturnsToIdle() {
        let viewModel = JoinRoomViewModel(code: "8704", state: .roomFull(capacity: 6))
        viewModel.retry()
        XCTAssertEqual(viewModel.code, "")
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Derived UI

    func testSlotsForIdleTwoDigits() {
        let slots = JoinRoomViewModel(code: "87").slots
        XCTAssertEqual(slots.map(\.style), [.filled, .filled, .active, .empty])
        XCTAssertEqual(slots.map(\.digit), ["8", "7", nil, nil])
    }

    func testSlotsForIdleEmptyCodeStartsWithActiveBox() {
        XCTAssertEqual(JoinRoomViewModel().slots.map(\.style), [.active, .empty, .empty, .empty])
    }

    func testSlotsForIdleFullCodeAllFilled() {
        XCTAssertEqual(JoinRoomViewModel(code: "8702").slots.map(\.style), Array(repeating: .filled, count: 4))
    }

    func testSlotsForInvalidCodeAllError() {
        let slots = JoinRoomViewModel(code: "8702", state: .invalidCode).slots
        XCTAssertEqual(slots.map(\.style), Array(repeating: .error, count: 4))
        XCTAssertEqual(slots.map(\.digit), ["8", "7", "0", "2"])
    }

    func testSlotsForInvalidShortCodeKeepsEmptyBoxesInErrorStyle() {
        let slots = JoinRoomViewModel(code: "87", state: .invalidCode).slots
        XCTAssertEqual(slots.map(\.style), Array(repeating: .error, count: 4))
        XCTAssertEqual(slots.map(\.digit), ["8", "7", nil, nil])
    }

    func testSlotsForRoomFullAllLocked() {
        let slots = JoinRoomViewModel(code: "8704", state: .roomFull(capacity: 6)).slots
        XCTAssertEqual(slots.map(\.style), Array(repeating: .locked, count: 4))
    }

    func testKeypadVisibilityOnlyHiddenForRoomFull() {
        XCTAssertTrue(JoinRoomViewModel().isKeypadVisible)
        XCTAssertTrue(JoinRoomViewModel(state: .invalidCode).isKeypadVisible)
        XCTAssertFalse(JoinRoomViewModel(state: .roomFull(capacity: 6)).isKeypadVisible)
    }

    func testAnnouncementPerState() {
        XCTAssertNil(JoinRoomViewModel().announcement)
        XCTAssertEqual(JoinRoomViewModel(state: .invalidCode).announcement, Strings.JoinRoom.invalidCodeMessage)
        XCTAssertEqual(JoinRoomViewModel(state: .roomFull(capacity: 6)).announcement, Strings.JoinRoom.roomFullTitle)
    }
}
