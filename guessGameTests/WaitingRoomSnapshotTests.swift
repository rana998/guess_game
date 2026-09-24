import SwiftUI
import XCTest
@testable import guessGame

/// Renders the waiting room in each role and state for comparing against the
/// owner and participant mockups.
@MainActor
final class WaitingRoomSnapshotTests: XCTestCase {
    private func render(_ viewModel: WaitingRoomViewModel, as name: String) throws {
        let directory = try SnapshotRenderer.outputDirectory()
        let data = try SnapshotRenderer.render(WaitingRoomView(viewModel: viewModel))
        try data.write(to: directory.appendingPathComponent("\(name).png"))
    }

    func testRenderOwner() throws {
        try render(WaitingRoomViewModel(session: WaitingRoomFixtures.ownerSession, copyToPasteboard: { _ in }), as: "WaitingRoom-owner")
    }

    func testRenderParticipant() throws {
        try render(WaitingRoomViewModel(session: WaitingRoomFixtures.participantSession, copyToPasteboard: { _ in }), as: "WaitingRoom-participant")
    }

    func testRenderOwnerTwoOfFour() throws {
        try render(WaitingRoomViewModel(session: WaitingRoomFixtures.smallOwnerSession, copyToPasteboard: { _ in }), as: "WaitingRoom-owner-2of4")
    }

    func testRenderOwnerStarting() throws {
        let viewModel = WaitingRoomViewModel(session: WaitingRoomFixtures.ownerSession, copyToPasteboard: { _ in })
        viewModel.startGame()
        try render(viewModel, as: "WaitingRoom-owner-starting")
    }
}
