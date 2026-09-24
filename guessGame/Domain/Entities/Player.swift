/// Someone in a room. `isOwner` marks the player who created it; `isReady` is
/// the lobby's readiness flag (handoff `roomState.players[].ready`).
struct Player: Identifiable, Hashable {
    let id: String
    var name: String
    var color: PlayerColor
    var isOwner: Bool
    var isReady: Bool = false
}
