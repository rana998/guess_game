/// Pushable destinations from the Home screen. Rooms are local for now — real
/// room creation/joining logic is a later phase.
enum HomeDestination: Hashable {
    case createRoom
    case joinRoom
    case howToPlay
    case homeSetting
    /// Pushed once a room code is accepted; carries the room that was joined.
    case enterName(Room)
    /// Pushed after creating or entering a room.
    case waitingRoom(WaitingRoomSession)
    /// Pushed when the waiting room starts the game; the game itself lives in
    /// the shared game store, seen as this player.
    case game(viewerId: String)
}
