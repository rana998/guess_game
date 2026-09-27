import SwiftUI

/// What a guesser sees while the describer picks and reads the word: who's
/// describing, that the timer hasn't started, when their own turn comes, and
/// who's guessing. Built to the 852×393 "WaitingForWord" mockup.
struct WaitingForWordView: View {
    @State private var viewModel: WaitingForWordViewModel

    init(viewModel: WaitingForWordViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// Vertical centers measured on the mockup canvas; everything is centered on x.
    private enum Metrics {
        static let centerX: CGFloat = 425
        static let pillCenterX: CGFloat = 425.5
        static let pillMaxWidth: CGFloat = 360
        static let pillY: CGFloat = 116
        static let dotsY: CGFloat = 152.5
        static let messageY: CGFloat = 177.5
        static let badgeY: CGFloat = 225.5
        static let avatarsY: CGFloat = 281.5
        static let captionY: CGFloat = 327.5
        static let badgeHeight: CGFloat = 30
        static let badgeHorizontalPadding: CGFloat = 13
        static let avatarSpacing: CGFloat = 4
    }

    var body: some View {
        GameCanvas {
            ZStack {
                if let describer = viewModel.describerAvatar {
                    DescriberStatusPill(avatar: describer, text: viewModel.describerPillText)
                        .accessibilityIdentifier("game.waiting.describerPill")
                        // Caps the hugging pill so a very long name truncates.
                        .frame(width: Metrics.pillMaxWidth)
                        .canvasCenter(x: Metrics.pillCenterX, y: Metrics.pillY)
                }
                WaitingDots()
                    .canvasCenter(x: Metrics.centerX, y: Metrics.dotsY)
                Text(viewModel.message)
                    .font(.bodyMedium)
                    .foregroundStyle(Color.black.opacity(0.55))
                    .canvasCenter(x: Metrics.centerX, y: Metrics.messageY)
                if let turnBadgeText = viewModel.turnBadgeText {
                    turnBadge(turnBadgeText)
                        .canvasCenter(x: Metrics.centerX, y: Metrics.badgeY)
                }
                guesserAvatars
                    .canvasCenter(x: Metrics.centerX, y: Metrics.avatarsY)
                Text(viewModel.guessersCountText)
                    .font(.bodyMedium)
                    .foregroundStyle(Color.black.opacity(0.55))
                    .accessibilityIdentifier("game.waiting.guessersCount")
                    .canvasCenter(x: Metrics.centerX, y: Metrics.captionY)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.screen.waitingForWord")
    }

    private func turnBadge(_ text: String) -> some View {
        Text(text)
            .font(.bodySmall)
            .foregroundStyle(Color.black.opacity(0.55))
            .padding(.horizontal, Metrics.badgeHorizontalPadding)
            .frame(height: Metrics.badgeHeight)
            .background(Color.white, in: Capsule())
            // 40% black is the mockup's dashed outline.
            .overlay(Capsule().strokeBorder(Color.black.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
            .accessibilityIdentifier("game.waiting.turnBadge")
    }

    // Reading order: the first guesser is the physical right.
    private var guesserAvatars: some View {
        HStack(spacing: Metrics.avatarSpacing) {
            ForEach(viewModel.guesserAvatars) { avatar in
                AvatarBadge(initial: avatar.initial, color: avatar.color.color, size: .strip)
            }
        }
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Waiting for the word", traits: .landscapeLeft) {
    WaitingForWordView(viewModel: WaitingForWordViewModel(
        useCases: .preview(seededWith: .sample(phase: .choosingWord)),
        viewerId: "lobby-2",
        clock: GameClock(currentDate: { Game.sampleNow })
    ))
}
#endif
