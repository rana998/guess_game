/// Why a round ended (handoff `round:end`): only a correct guess awards points.
enum RoundEndReason: Hashable {
    case guessed(winnerId: String)
    case timeUp
    case endedByDescriber
}
