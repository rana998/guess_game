import Foundation

/// Ends the round when its time runs out.
protocol RoundTimerUseCase {
    /// true only on the call that ends the round.
    @discardableResult func expireIfDue(now: Date) -> Bool
}
