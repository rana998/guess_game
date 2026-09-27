/// Where a round stands: the describer picks a difficulty and draws a word, reads
/// it, then describes (the timer runs) until the round ends.
enum RoundPhase: Hashable {
    case choosingWord
    case wordDrawn
    case describing
    case ended(RoundEndReason)
}
