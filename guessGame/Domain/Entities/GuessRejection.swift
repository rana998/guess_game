/// Why a guess was refused without being recorded.
enum GuessRejection: Hashable {
    case noGame
    case notDescribing
    case timeUp
    case unknownPlayer
    case describerCannotGuess
    case noClueYet
    case empty
}
