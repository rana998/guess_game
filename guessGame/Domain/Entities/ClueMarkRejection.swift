/// Why the describer's tag on an image was refused.
enum ClueMarkRejection: Hashable {
    case noGame
    case notDescriber
    case notDescribing
    case tileOutOfRange
    case tileAlreadyMarked
    case limitReached
}
