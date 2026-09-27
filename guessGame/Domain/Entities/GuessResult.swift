/// What happened to a submitted guess.
enum GuessResult: Hashable {
    case correct
    case incorrect
    case rejected(GuessRejection)
}
