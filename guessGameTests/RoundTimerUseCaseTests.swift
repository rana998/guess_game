import XCTest
@testable import guessGame

final class RoundTimerUseCaseTests: XCTestCase {
    private let startDate = GameFixtures.startDate

    func testNothingHappensBeforeTheDeadline() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        XCTAssertFalse(RoundTimerUseCaseImpl(repository: repository).expireIfDue(now: startDate.addingTimeInterval(59.9)))
        XCTAssertEqual(repository.game?.currentRound.phase, .describing)
        XCTAssertEqual(repository.saveCount, 0)
    }

    func testTheRoundEndsAtTheDeadlineWithoutPoints() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        XCTAssertTrue(RoundTimerUseCaseImpl(repository: repository).expireIfDue(now: startDate.addingTimeInterval(60)))
        XCTAssertEqual(repository.game?.currentRound.phase, .ended(.timeUp))
        XCTAssertEqual(repository.game?.scores.values.reduce(0, +), 0)
    }

    func testTheEndIsRecordedAtTheDeadlineEvenWhenNoticedLate() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        RoundTimerUseCaseImpl(repository: repository).expireIfDue(now: startDate.addingTimeInterval(75))
        XCTAssertEqual(repository.game?.currentRound.endedAt, startDate.addingTimeInterval(60))
    }

    func testExpiringTwiceSavesOnce() {
        let repository = GameRepositoryFake(game: GameFixtures.game())
        let roundTimer = RoundTimerUseCaseImpl(repository: repository)
        roundTimer.expireIfDue(now: startDate.addingTimeInterval(61))
        XCTAssertFalse(roundTimer.expireIfDue(now: startDate.addingTimeInterval(62)))
        XCTAssertEqual(repository.saveCount, 1)
    }

    func testOnlyARunningRoundExpires() {
        for phase in [RoundPhase.choosingWord, .wordDrawn, .ended(.endedByDescriber)] {
            let repository = GameRepositoryFake(game: GameFixtures.game(phase: phase))
            XCTAssertFalse(RoundTimerUseCaseImpl(repository: repository).expireIfDue(now: startDate.addingTimeInterval(500)))
            XCTAssertEqual(repository.saveCount, 0)
        }
    }
}
