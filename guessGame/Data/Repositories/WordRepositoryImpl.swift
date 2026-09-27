/// Serves the bundled Arabic word lists.
struct WordRepositoryImpl: WordRepository {
    func words(for difficulty: Difficulty) -> [String] {
        switch difficulty {
        case .easy: ArabicWordList.easy
        case .medium: ArabicWordList.medium
        case .hard: ArabicWordList.hard
        }
    }
}
