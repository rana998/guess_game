import Foundation

/// One describer's turn: the word they drew, the images they tagged and the
/// guesses made against it (handoff `roundState`).
struct Round: Hashable {
    /// The describer's 8×4 board; a tile's identity is its index in reading order.
    static let tileCount = 32

    let index: Int
    let describerId: String
    var phase: RoundPhase = .choosingWord
    var difficulty: Difficulty?
    var word: String?
    var endsAt: Date?
    var endedAt: Date?
    var marks: [ClueMark] = []
    var guesses: [Guess] = []
    /// Points the round gave out, by player id; empty unless the word was guessed.
    var awardedPoints: [String: Int] = [:]

    var isDescribing: Bool { phase == .describing }

    var isEnded: Bool { endReason != nil }

    var endReason: RoundEndReason? {
        if case .ended(let reason) = phase { return reason }
        return nil
    }

    var hasAnyMark: Bool { !marks.isEmpty }

    /// The "?" and cube marks, in the order they were placed.
    var mainIdeaMarks: [ClueMark] { marks.filter { mark in mark.tag.belongsToMainIdea } }

    var secondaryIdeaMark: ClueMark? { marks.first { mark in mark.tag == .secondaryIdea } }

    func count(of tag: ClueTag) -> Int { marks.filter { mark in mark.tag == tag }.count }

    func mark(onTile tileIndex: Int) -> ClueMark? { marks.first { mark in mark.tileIndex == tileIndex } }

    /// Whole seconds left, rounded up, and frozen at the moment the round ended.
    /// nil until describing starts.
    func remainingSeconds(at date: Date) -> Int? {
        guard let endsAt else { return nil }
        let countedUntil = min(date, endedAt ?? date)
        return max(0, Int(ceil(endsAt.timeIntervalSince(countedUntil))))
    }
}
