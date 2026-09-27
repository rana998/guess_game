import Observation

/// The game held in memory on this device, shared by every screen that shows
/// it. The networked store replaces this once games span devices.
@Observable
final class GameRepositoryImpl: GameRepository {
    private(set) var game: Game?

    func save(_ game: Game) {
        self.game = game
    }

    func clear() {
        game = nil
    }
}
