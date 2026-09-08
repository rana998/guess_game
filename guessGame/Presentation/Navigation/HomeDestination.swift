/// Pushable destinations from the Home screen. UI-only placeholders for now —
/// real room creation/joining logic is a later phase.
enum HomeDestination: Hashable {
    case createRoom
    case joinRoom
    case howToPlay
}
