/// How the person looking at a room takes part in it: the owner who created
/// it, or a participant who joined. The viewer's role, not a player field.
enum RoomRole: Hashable {
    case owner
    case participant
}
