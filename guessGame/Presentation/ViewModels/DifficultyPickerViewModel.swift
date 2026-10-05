import Observation

/// The describer's first step: pick how hard a word to draw.
@Observable
final class DifficultyPickerViewModel {
    /// Medium starts selected, as in the mockup.
    private(set) var selectedDifficulty: Difficulty = .medium

    @ObservationIgnored private let useCases: GameUseCases
    @ObservationIgnored private let viewerId: String

    init(useCases: GameUseCases, viewerId: String, clock: GameClock) {
        self.useCases = useCases
        self.viewerId = viewerId
    }

    var options: [DifficultyOption] { Difficulty.allCases.map { difficulty in DifficultyOption(difficulty: difficulty) } }

    func select(_ difficulty: Difficulty) {
        selectedDifficulty = difficulty
    }

    @discardableResult
    func drawWord() -> Bool {
        useCases.describerTurn.drawWord(difficulty: selectedDifficulty, by: viewerId)
    }
}
