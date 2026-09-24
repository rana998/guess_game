/// Where the waiting room is: still gathering players, or starting the game.
/// Once starting, the room is locked (no ready, remove, duration or start).
enum WaitingRoomPhase: Equatable {
    case waiting
    case starting
}
