import Foundation

final class StartGameUseCaseImpl: StartGameUseCase {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func execute(range: ClosedRange<Int>) -> GameSession {
        let target = repository.generateTarget(in: range)
        return GameSession(id: UUID(), targetNumber: target, range: range, attemptCount: 0, isFinished: false)
    }
}
