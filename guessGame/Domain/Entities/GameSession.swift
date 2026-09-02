import Foundation

/// A single round of the guessing game: the hidden target, its valid range, and progress so far.
struct GameSession: Equatable {
    let id: UUID
    let targetNumber: Int
    let range: ClosedRange<Int>
    var attemptCount: Int
    var isFinished: Bool
}
