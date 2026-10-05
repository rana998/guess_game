import XCTest
@testable import guessGame

final class DifficultyPickerViewModelTests: XCTestCase {
    private let describerId = GameFixtures.playerId(0)

    private func makeViewModel(repository: GameRepositoryFake) -> DifficultyPickerViewModel {
        DifficultyPickerViewModel(
            useCases: GameFixtures.makeUseCases(repository: repository, words: [.hard: ["حرية"], .medium: ["زرافة"]]),
            viewerId: describerId,
            clock: GameClock(currentDate: { GameFixtures.startDate })
        )
    }

    private var choosingRepository: GameRepositoryFake {
        GameRepositoryFake(game: GameFixtures.game(phase: .choosingWord, difficulty: nil, word: nil, endsAt: nil))
    }

    func testMediumStartsSelected() {
        XCTAssertEqual(makeViewModel(repository: choosingRepository).selectedDifficulty, .medium)
    }

    func testOptionsInReadingOrderWithTheirPoints() {
        let options = makeViewModel(repository: choosingRepository).options
        XCTAssertEqual(options.map(\.difficulty), [.easy, .medium, .hard])
        XCTAssertEqual(options.map(\.title), ["سهل", "متوسط", "صعب"])
        XCTAssertEqual(options.map(\.pointsText), ["+1", "+2", "+3"])
        XCTAssertEqual(options.map(\.accessibilityLabel), ["سهل، نقطة واحدة", "متوسط، نقطتان", "صعب، 3 نقاط"])
    }

    func testDrawingUsesTheSelectedDifficulty() {
        let repository = choosingRepository
        let viewModel = makeViewModel(repository: repository)
        viewModel.select(.hard)
        XCTAssertTrue(viewModel.drawWord())
        XCTAssertEqual(repository.game?.currentRound.phase, .wordDrawn)
        XCTAssertEqual(repository.game?.currentRound.difficulty, .hard)
        XCTAssertEqual(repository.game?.currentRound.word, "حرية")
    }
}
