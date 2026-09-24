/// Everything the waiting room needs to open: the room, who is looking at it, and as what.
struct WaitingRoomSession: Hashable {
    let room: Room
    let role: RoomRole
    let currentPlayerId: String

    /// The joining player's session: appends them as a non-owner who isn't ready yet.
    /// nil when the room is already full.
    static func joining(_ room: Room, name: String, color: PlayerColor, playerId: String) -> WaitingRoomSession? {
        guard room.players.count < room.capacity else { return nil }
        var joined = room
        joined.players.append(Player(id: playerId, name: name, color: color, isOwner: false, isReady: false))
        return WaitingRoomSession(room: joined, role: .participant, currentPlayerId: playerId)
    }
}
