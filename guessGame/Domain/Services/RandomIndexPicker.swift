/// Randomness the game rules need (the first describer, the drawn word), injected
/// so tests can fix it.
struct RandomIndexPicker {
    let pickIndex: (_ count: Int) -> Int

    static let system = RandomIndexPicker { count in Int.random(in: 0..<count) }

    /// nil for an empty range; otherwise always within 0..<count, whatever
    /// `pickIndex` returns.
    func index(below count: Int) -> Int? {
        guard count > 0 else { return nil }
        let remainder = pickIndex(count) % count
        return remainder < 0 ? remainder + count : remainder
    }
}
