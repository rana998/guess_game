/// Someone in a room. `isOwner` marks the player who created it.
struct Player: Identifiable, Hashable {
    let id: String
    var name: String
    var color: PlayerColor
    var isOwner: Bool
}
