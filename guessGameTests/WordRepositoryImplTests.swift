import XCTest
@testable import guessGame

final class WordRepositoryImplTests: XCTestCase {
    private let repository = WordRepositoryImpl()
    private let normalizer = ArabicTextNormalizer()

    func testEveryLevelHasFifteenToTwentyWords() {
        for difficulty in Difficulty.allCases {
            XCTAssertTrue((15...20).contains(repository.words(for: difficulty).count), "\(difficulty)")
        }
    }

    func testWordsAreTrimmedAndNonEmpty() {
        for difficulty in Difficulty.allCases {
            for word in repository.words(for: difficulty) {
                XCTAssertFalse(word.isEmpty)
                XCTAssertEqual(word, word.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    func testNoWordRepeatsWithinOrAcrossLevels() {
        let allWords = Difficulty.allCases.flatMap { difficulty in repository.words(for: difficulty) }
        let normalizedWords = allWords.map { word in normalizer.normalize(word) }
        XCTAssertEqual(Set(normalizedWords).count, allWords.count)
    }

    func testWordsCarryNoDiacritics() {
        let diacritics = 0x064B...0x065F
        for difficulty in Difficulty.allCases {
            for word in repository.words(for: difficulty) {
                XCTAssertFalse(word.unicodeScalars.contains { scalar in diacritics.contains(Int(scalar.value)) }, word)
            }
        }
    }
}
