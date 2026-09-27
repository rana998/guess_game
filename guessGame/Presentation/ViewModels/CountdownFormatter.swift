import Foundation

/// The round timer's "m:ss" text, in ASCII digits like the mockups.
enum CountdownFormatter {
    static func text(seconds: Int) -> String {
        let clampedSeconds = max(0, seconds)
        return String(format: "%d:%02d", clampedSeconds / 60, clampedSeconds % 60)
    }

    /// The full round length before describing starts.
    static func text(for game: Game, at date: Date) -> String {
        text(seconds: game.currentRound.remainingSeconds(at: date) ?? game.roundSeconds)
    }
}
