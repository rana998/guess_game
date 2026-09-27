/// The describing order: starting from one player, then round-robin through the
/// room order, so everyone describes exactly once.
enum TurnOrder {
    static func rotation(of playerIds: [String], startingAt startIndex: Int) -> [String] {
        guard !playerIds.isEmpty else { return [] }
        let firstIndex = ((startIndex % playerIds.count) + playerIds.count) % playerIds.count
        return Array(playerIds[firstIndex...] + playerIds[..<firstIndex])
    }
}
