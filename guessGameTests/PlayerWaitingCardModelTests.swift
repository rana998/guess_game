import XCTest
@testable import guessGame

final class PlayerWaitingCardModelTests: XCTestCase {
    private let owner = Player(id: "o", name: "نهى", color: .green, isOwner: true, isReady: true)
    private let other = Player(id: "p", name: "سلمان", color: .teal, isOwner: false, isReady: false)

    private func model(_ player: Player, viewer: String, role: RoomRole) -> PlayerWaitingCard.Model {
        PlayerWaitingCard.Model(player: player, currentPlayerId: viewer, viewerRole: role)
    }

    func testOwnerLookingAtTheirOwnCard() {
        let card = model(owner, viewer: "o", role: .owner)
        XCTAssertEqual(card.caption, "انت صاحب الغرفة")
        XCTAssertTrue(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testOwnerLookingAtAnotherPlayersCard() {
        let card = model(other, viewer: "o", role: .owner)
        XCTAssertNil(card.caption)
        XCTAssertFalse(card.isHighlighted)
        XCTAssertTrue(card.showsRemoveButton)
    }

    func testParticipantLookingAtTheirOwnCard() {
        let card = model(other, viewer: "p", role: .participant)
        XCTAssertEqual(card.caption, "أنت")
        XCTAssertTrue(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testParticipantLookingAtTheOwnersCard() {
        let card = model(owner, viewer: "p", role: .participant)
        XCTAssertEqual(card.caption, "مالك الغرفة")
        XCTAssertFalse(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testParticipantLookingAtAnotherParticipantsCard() {
        let card = model(other, viewer: "x", role: .participant)
        XCTAssertNil(card.caption)
        XCTAssertFalse(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testAccessibilityLabelJoinsNameCaptionAndState() {
        XCTAssertEqual(model(owner, viewer: "o", role: .owner).accessibilityLabel, "نهى، انت صاحب الغرفة، جاهز")
        XCTAssertEqual(model(other, viewer: "o", role: .owner).accessibilityLabel, "سلمان، في الانتظار")
    }

    func testRemoveLabelNamesThePlayer() {
        XCTAssertEqual(model(other, viewer: "o", role: .owner).removeAccessibilityLabel, "إزالة سلمان")
    }

    func testInitialReadinessAndIdentityComeFromThePlayer() {
        let card = model(other, viewer: "o", role: .owner)
        XCTAssertEqual(card.initial, "س")
        XCTAssertFalse(card.isReady)
        XCTAssertTrue(model(owner, viewer: "o", role: .owner).isReady)
        XCTAssertEqual(card.id, "p")
        XCTAssertEqual(card.color, PlayerColor.teal.color)
    }
}
