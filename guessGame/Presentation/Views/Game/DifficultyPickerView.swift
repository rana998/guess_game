import SwiftUI

/// The describer picks easy, medium or hard (each worth more points) and draws
/// a word. Built to the 852×393 "Level WordCard" mockup.
struct DifficultyPickerView: View {
    @State private var viewModel: DifficultyPickerViewModel

    init(viewModel: DifficultyPickerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// Centers measured on the mockup canvas.
    private enum Metrics {
        static let centerX: CGFloat = 425
        static let titleY: CGFloat = 66
        static let subtitleY: CGFloat = 107
        static let cardsY: CGFloat = 182
        static let cardWidth: CGFloat = 226
        static let cardSpacing: CGFloat = 16
        static let drawY: CGFloat = 301
        static let drawSize = CGSize(width: 298, height: 54)
    }

    var body: some View {
        GameCanvas {
            ZStack {
                Text(Strings.DifficultyPicker.title)
                    .font(.inputText)
                    .foregroundStyle(Color.black)
                    .accessibilityAddTraits(.isHeader)
                    .canvasCenter(x: Metrics.centerX, y: Metrics.titleY)
                Text(Strings.DifficultyPicker.subtitle)
                    .font(.bodyLarge)
                    .foregroundStyle(Color.black.opacity(0.55))
                    .canvasCenter(x: Metrics.centerX, y: Metrics.subtitleY)
                cards
                    .canvasCenter(x: Metrics.centerX, y: Metrics.cardsY)
                Button(Strings.DifficultyPicker.draw) { viewModel.drawWord() }
                    .buttonStyle(.appGameAction(fill: .brandYellow, width: Metrics.drawSize.width, height: Metrics.drawSize.height))
                    .accessibilityIdentifier("game.drawWord")
                    .canvasCenter(x: Metrics.centerX, y: Metrics.drawY)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.screen.difficultyPicker")
    }

    // Reading order: easy is the physical right.
    private var cards: some View {
        HStack(spacing: Metrics.cardSpacing) {
            ForEach(viewModel.options) { option in
                SelectablePillButton(
                    value: option.title,
                    caption: option.pointsText,
                    isSelected: option.difficulty == viewModel.selection,
                    width: Metrics.cardWidth,
                    size: .large
                ) {
                    viewModel.select(option.difficulty)
                }
                .accessibilityLabel(option.accessibilityLabel)
                .accessibilityIdentifier("game.difficulty.\(option.difficulty)")
            }
        }
    }
}

#if DEBUG
#Preview("Difficulty picker", traits: .landscapeLeft) {
    DifficultyPickerView(viewModel: DifficultyPickerViewModel(
        useCases: .preview(seededWith: .sample(phase: .choosingWord)),
        viewerId: "lobby-0",
        clock: GameClock(currentDate: { Game.sampleNow })
    ))
}
#endif
