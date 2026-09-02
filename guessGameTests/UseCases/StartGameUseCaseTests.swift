import XCTest
@testable import guessGame

final class StartGameUseCaseTests: XCTestCase {
    func test_execute_returnsSessionWithTargetFromRepository() {
        let repository = MockGameRepository(fixedTarget: 42)
        let sut = StartGameUseCaseImpl(repository: repository)

        let session = sut.execute(range: 1...100)

        XCTAssertEqual(session.targetNumber, 42)
    }

    func test_execute_returnsSessionWithZeroAttemptsAndNotFinished() {
        let repository = MockGameRepository(fixedTarget: 1)
        let sut = StartGameUseCaseImpl(repository: repository)

        let session = sut.execute(range: 1...10)

        XCTAssertEqual(session.attemptCount, 0)
        XCTAssertFalse(session.isFinished)
    }

    func test_execute_passesRangeThroughToSession() {
        let repository = MockGameRepository(fixedTarget: 5)
        let sut = StartGameUseCaseImpl(repository: repository)
        let range = 1...50

        let session = sut.execute(range: range)

        XCTAssertEqual(session.range, range)
        XCTAssertEqual(repository.lastRequestedRange, range)
    }
}
