import Foundation
import Observation

/// The time the round screens show and act on. Only intents and the round
/// ticker refresh it, so a view that reads `now` redraws once per tick and
/// every timestamped move uses the current time, not the last tick's.
@Observable
final class GameClock {
    private(set) var now: Date
    @ObservationIgnored private let currentDate: () -> Date

    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
        now = currentDate()
    }

    @discardableResult
    func refresh() -> Date {
        now = currentDate()
        return now
    }
}
