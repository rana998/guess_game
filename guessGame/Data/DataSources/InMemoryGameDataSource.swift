/// Concrete source of randomness backing GameRepositoryImpl. In-memory only — no persistence.
final class InMemoryGameDataSource {
    func randomNumber(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range)
    }
}
