import XCTest
@testable import guessGame

final class GameRepositoryImplTests: XCTestCase {
    func testStartsEmptyThenHoldsTheSavedGameUntilCleared() {
        let repository = GameRepositoryImpl()
        XCTAssertNil(repository.game)
        let game = GameFixtures.game()
        repository.save(game)
        XCTAssertEqual(repository.game, game)
        repository.clear()
        XCTAssertNil(repository.game)
    }
}
