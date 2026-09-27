/// What happened to a request to tag an image on the describer's board.
enum ClueMarkResult: Hashable {
    case placed
    case rejected(ClueMarkRejection)
}
