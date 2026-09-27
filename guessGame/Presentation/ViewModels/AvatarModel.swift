/// What a player's avatar shows: their initial in their color.
struct AvatarModel: Identifiable, Hashable {
    let id: String
    let name: String
    let initial: String
    let color: PlayerColor

    init(player: Player) {
        id = player.id
        name = player.name
        initial = AvatarBadge.initial(from: player.name, placeholder: "")
        color = player.color
    }
}
