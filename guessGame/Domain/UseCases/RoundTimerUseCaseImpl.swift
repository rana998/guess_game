import Foundation

struct RoundTimerUseCaseImpl: RoundTimerUseCase {
    let repository: GameRepository

    @discardableResult
    func expireIfDue(now: Date) -> Bool {
        guard var game = repository.game,
              game.currentRound.isDescribing,
              let endsAt = game.currentRound.endsAt,
              now >= endsAt else { return false }
        game.currentRound.phase = .ended(.timeUp)
        // The round ended when time ran out, however late the check noticed.
        game.currentRound.endedAt = endsAt
        repository.save(game)
        return true
    }
}
