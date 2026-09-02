/// Abstracts the source of randomness so Domain use cases stay deterministic and testable.
protocol GameRepository {
    func generateTarget(in range: ClosedRange<Int>) -> Int
}
