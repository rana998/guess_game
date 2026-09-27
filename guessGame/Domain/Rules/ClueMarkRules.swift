/// How many images each tag may be pinned on per round, and whether a new tag
/// may go on a tile. The three limits are independent of each other.
enum ClueMarkRules {
    static func limit(for tag: ClueTag) -> Int {
        switch tag {
        case .mainIdea: 1
        case .detail: 10
        case .secondaryIdea: 1
        }
    }

    static func remaining(_ tag: ClueTag, in round: Round) -> Int {
        max(0, limit(for: tag) - round.count(of: tag))
    }

    static func hasAnyRemaining(in round: Round) -> Bool {
        ClueTag.allCases.contains { tag in remaining(tag, in: round) > 0 }
    }

    /// nil when the tag may go on the tile. Tags are final, and the order in
    /// which tags are used is free (a cube may come before the "?").
    static func rejection(placing tag: ClueTag, onTile tileIndex: Int, in round: Round) -> ClueMarkRejection? {
        guard round.isDescribing else { return .notDescribing }
        guard (0..<Round.tileCount).contains(tileIndex) else { return .tileOutOfRange }
        guard round.mark(onTile: tileIndex) == nil else { return .tileAlreadyMarked }
        guard remaining(tag, in: round) > 0 else { return .limitReached }
        return nil
    }
}
