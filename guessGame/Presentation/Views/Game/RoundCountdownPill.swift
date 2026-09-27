import SwiftUI

/// The countdown in a round screen's header. It takes the text as a closure and
/// reads it in its own body, so only this pill observes the clock and redraws
/// on every tick, not the whole board.
struct RoundCountdownPill: View {
    let timerText: () -> String

    var body: some View {
        RoundTimerPill(text: timerText())
            .accessibilityIdentifier("game.timer")
    }
}
