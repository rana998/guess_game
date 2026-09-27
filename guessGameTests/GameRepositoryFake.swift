@testable import guessGame

/// An in-memory game store that counts saves, so tests can prove refused moves
/// write nothing.
final class GameRepositoryFake: GameRepository {
    private(set) var game: Game?
    private(set) var saveCount = 0

    init(game: Game? = nil) {
        self.game = game
    }

    func save(_ game: Game) {
        self.game = game
        saveCount += 1
    }

    func clear() {
        game = nil
    }
}
