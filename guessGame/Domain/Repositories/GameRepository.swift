/// Where the game in progress lives. Implementations must be `@Observable`:
/// every screen reads the game through it and redraws when any player's move
/// saves a new one.
protocol GameRepository: AnyObject {
    var game: Game? { get }
    func save(_ game: Game)
    func clear()
}
