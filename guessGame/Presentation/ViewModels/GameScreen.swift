/// Which round screen a viewer sees: the describer's three, or the guessers' two.
enum GameScreen: Hashable {
    case difficultyPicker
    case wordCard
    case waitingForWord
    case describerBoard
    case guesserBoard
}
