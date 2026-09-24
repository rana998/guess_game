/// A room a player can join: the code that opens it, how many players it
/// holds at most, who is in it now, and how long each round lasts.
struct Room: Hashable {
    static let minimumPlayers = 3
    static let maximumPlayers = 6
    static let defaultRoundSeconds = 60
    /// The round lengths the owner can pick, shared by Create Room and the waiting room.
    static let roundSecondsOptions = [30, 60, 90]

    var code: String
    var capacity: Int
    var players: [Player]
    var roundSeconds: Int = Room.defaultRoundSeconds
}
