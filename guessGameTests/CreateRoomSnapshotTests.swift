import SwiftUI
import UIKit
import XCTest
@testable import guessGame

/// Create Room's rendered baseline: shared components changed for the waiting
/// room must leave this snapshot pixel-identical.
@MainActor
final class CreateRoomSnapshotTests: XCTestCase {
    func testRenderCreateRoom() throws {
        let directory = try SnapshotRenderer.outputDirectory()
        XCTAssertNotNil(UIFont(name: "Almarai-ExtraBold", size: 12))
        let data = try SnapshotRenderer.render(CreateRoomView(viewModel: CreateRoomViewModel()))
        try data.write(to: directory.appendingPathComponent("CreateRoom.png"))
    }
}
