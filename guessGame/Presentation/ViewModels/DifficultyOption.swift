/// One card in the difficulty picker: the level, its name and its points.
struct DifficultyOption: Identifiable, Hashable {
    let difficulty: Difficulty
    let title: String
    let pointsText: String
    let accessibilityLabel: String

    var id: Difficulty { difficulty }

    init(difficulty: Difficulty) {
        let points = ScoringRules.guesserPoints(for: difficulty)
        self.difficulty = difficulty
        title = difficulty.title
        pointsText = Strings.Difficulties.points(points)
        accessibilityLabel = Strings.Difficulties.accessibilityLabel(name: difficulty.title, points: points)
    }
}
