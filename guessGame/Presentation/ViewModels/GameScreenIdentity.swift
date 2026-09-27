/// Identifies one showing of a round screen. A new round, viewer or screen
/// gets a fresh screen state (typed guess, open picker, scroll positions);
/// live moves by other players keep it.
struct GameScreenIdentity: Hashable {
    let roundIndex: Int
    let viewerId: String
    let screen: GameScreen
}
