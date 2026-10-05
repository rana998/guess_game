import XCTest
@testable import guessGame

final class PlayerWaitingCardModelTests: XCTestCase {
    private let owner = Player(id: "o", name: "نهى", color: .green, isOwner: true, isReady: true)
    private let participant = Player(id: "p", name: "سلمان", color: .teal, isOwner: false, isReady: false)

    private func model(_ player: Player, viewerId: String, role: RoomRole) -> PlayerWaitingCard.Model {
        PlayerWaitingCard.Model(player: player, currentPlayerId: viewerId, viewerRole: role)
    }

    func testOwnerLookingAtTheirOwnCard() {
        let card = model(owner, viewerId: "o", role: .owner)
        XCTAssertEqual(card.caption, "انت صاحب الغرفة")
        XCTAssertTrue(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testOwnerLookingAtAnotherPlayersCard() {
        let card = model(participant, viewerId: "o", role: .owner)
        XCTAssertNil(card.caption)
        XCTAssertFalse(card.isHighlighted)
        XCTAssertTrue(card.showsRemoveButton)
    }

    func testParticipantLookingAtTheirOwnCard() {
        let card = model(participant, viewerId: "p", role: .participant)
        XCTAssertEqual(card.caption, "أنت")
        XCTAssertTrue(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testParticipantLookingAtTheOwnersCard() {
        let card = model(owner, viewerId: "p", role: .participant)
        XCTAssertEqual(card.caption, "مالك الغرفة")
        XCTAssertFalse(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testParticipantLookingAtAnotherParticipantsCard() {
        let card = model(participant, viewerId: "x", role: .participant)
        XCTAssertNil(card.caption)
        XCTAssertFalse(card.isHighlighted)
        XCTAssertFalse(card.showsRemoveButton)
    }

    func testAccessibilityLabelJoinsNameCaptionAndState() {
        XCTAssertEqual(model(owner, viewerId: "o", role: .owner).accessibilityLabel, "نهى، انت صاحب الغرفة، جاهز")
        XCTAssertEqual(model(participant, viewerId: "o", role: .owner).accessibilityLabel, "سلمان، في الانتظار")
    }

    func testRemoveLabelNamesThePlayer() {
        XCTAssertEqual(model(participant, viewerId: "o", role: .owner).removeAccessibilityLabel, "إزالة سلمان")
    }

    func testInitialReadinessAndIdentityComeFromThePlayer() {
        let card = model(participant, viewerId: "o", role: .owner)
        XCTAssertEqual(card.initial, "س")
        XCTAssertFalse(card.isReady)
        XCTAssertTrue(model(owner, viewerId: "o", role: .owner).isReady)
        XCTAssertEqual(card.id, "p")
        XCTAssertEqual(card.color, PlayerColor.teal.color)
    }
}
