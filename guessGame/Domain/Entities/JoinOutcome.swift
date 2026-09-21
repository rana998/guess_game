/// What looking up a room code produced. The join use case will return this;
/// until it exists, Join Room's default resolver rejects every code.
enum JoinOutcome: Equatable {
    case joined(Room)
    case invalidCode
    case roomFull(capacity: Int)
}
