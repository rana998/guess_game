@testable import guessGame

/// Serves fixed word lists; levels not given have no words.
struct WordRepositoryStub: WordRepository {
    var wordsByDifficulty: [Difficulty: [String]] = [:]

    func words(for difficulty: Difficulty) -> [String] {
        wordsByDifficulty[difficulty] ?? []
    }
}
