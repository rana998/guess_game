/// A room a player can join: the code that opens it, how many players it
/// holds at most, and who is in it now.
struct Room: Hashable {
    var code: String
    var capacity: Int
    var players: [Player]
}
