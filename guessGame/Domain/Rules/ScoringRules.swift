/// Points for the first correct guess (the How to Play rules): the guesser gets
/// the word's difficulty points, the describer one point.
enum ScoringRules {
    static let describerPoints = 1

    static func guesserPoints(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy: 1
        case .medium: 2
        case .hard: 3
        }
    }
}
