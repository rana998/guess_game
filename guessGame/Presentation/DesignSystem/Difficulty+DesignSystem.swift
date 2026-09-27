/// How each difficulty is named. The levels themselves are Domain.
extension Difficulty {
    var title: String {
        switch self {
        case .easy: Strings.Difficulties.easy
        case .medium: Strings.Difficulties.medium
        case .hard: Strings.Difficulties.hard
        }
    }
}
