/// What Join Room is showing, apart from the digits typed so far. The screen's
/// keypad-or-card, caption-or-banner and box styling all follow from this.
enum JoinRoomState: Equatable {
    /// Entering a code; no result to show yet.
    case idle
    /// The submitted code doesn't open a room.
    case invalidCode
    /// The room exists but has no seat left. `capacity` is that room's player
    /// limit (3–6), shown in the card's badge and message.
    case roomFull(capacity: Int)
}
