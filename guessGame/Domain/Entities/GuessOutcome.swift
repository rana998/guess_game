/// Feedback for a single guess against the session's target number.
enum GuessOutcome: Equatable {
    case tooLow
    case tooHigh
    case correct
}
