/// Pushable destinations from the Home screen. The screens are UI-only for now —
/// real room creation/joining logic is a later phase.
enum HomeDestination: Hashable {
    case createRoom
    case joinRoom
    case howToPlay
    case homeSetting
    /// Pushed once a room code is accepted; carries the room that was joined.
    case enterName(Room)
}
