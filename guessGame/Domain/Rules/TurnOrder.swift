/// The describing order: starting from one player, then round-robin through the
/// room order, so everyone describes exactly once.
enum TurnOrder {
    static func rotation(of playerIds: [String], startingAt startIndex: Int) -> [String] {
        guard !playerIds.isEmpty else { return [] }
        let playerCount = playerIds.count
        let wrappedStartIndex = ((startIndex % playerCount) + playerCount) % playerCount
        return Array(playerIds[wrappedStartIndex...] + playerIds[..<wrappedStartIndex])
    }
}
