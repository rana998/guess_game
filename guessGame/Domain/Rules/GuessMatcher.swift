/// Decides whether a guess names the secret word, forgiving how it was typed:
/// normalized Arabic, spaces ignored, and an optional definite article.
struct GuessMatcher {
    var normalizer = ArabicTextNormalizer()

    func matches(_ guess: String, word: String) -> Bool {
        let guessWords = normalizer.normalize(guess).split(separator: " ").map(String.init)
        let secretWords = normalizer.normalize(word).split(separator: " ").map(String.init)
        guard !guessWords.isEmpty, !secretWords.isEmpty else { return false }
        // Either form may match: "وحيدالقرن" only equals "وحيد القرن" with its
        // article kept, while "زرافة" only equals "الزرافة" with it dropped.
        return guessWords.joined() == secretWords.joined()
            || Self.withoutArticles(guessWords) == Self.withoutArticles(secretWords)
    }

    /// Drops a leading "ال" from words long enough to carry one, so short words
    /// that merely start with those letters stay intact.
    private static func withoutArticles(_ words: [String]) -> String {
        words.map { word in
            word.count > 3 && word.hasPrefix("ال") ? String(word.dropFirst(2)) : word
        }
        .joined()
    }
}
