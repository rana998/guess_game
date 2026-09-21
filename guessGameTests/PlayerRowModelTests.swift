import XCTest
@testable import guessGame

final class PlayerRowModelTests: XCTestCase {
    private let ownerCaption = "مالك الغرفة"

    private func model(name: String, isOwner: Bool, color: PlayerColor = .green) -> PlayerRow.Model {
        PlayerRow.Model(player: Player(id: "p", name: name, color: color, isOwner: isOwner), ownerCaption: ownerCaption)
    }

    func testOwnerRowHasTheCaption() {
        XCTAssertEqual(model(name: "نهى", isOwner: true).caption, ownerCaption)
    }

    func testNonOwnerRowHasNoCaption() {
        XCTAssertNil(model(name: "سلمان", isOwner: false).caption)
    }

    func testAccessibilityLabelIncludesTheCaptionOnlyForTheOwner() {
        XCTAssertEqual(model(name: "نهى", isOwner: true).accessibilityLabel, "نهى، مالك الغرفة")
        XCTAssertEqual(model(name: "سلمان", isOwner: false).accessibilityLabel, "سلمان")
    }

    func testInitialIsTheNamesFirstLetter() {
        XCTAssertEqual(model(name: "سلمان", isOwner: false).initial, "س")
    }

    func testEmptyNameHasABlankInitial() {
        XCTAssertEqual(model(name: "", isOwner: false).initial, "")
    }

    func testRowKeepsThePlayersIdentityAndColor() {
        let row = model(name: "لمى", isOwner: false, color: .gold)
        XCTAssertEqual(row.id, "p")
        XCTAssertEqual(row.color, PlayerColor.gold.color)
    }
}
