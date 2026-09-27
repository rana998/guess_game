import SwiftUI

/// The tag picker over the describer's board: the chosen tile, its number, and
/// the three tags, greyed out once used up. Built to the 852×393 "BadgePicker"
/// mockup; the card is centered on the canvas.
struct BadgePickerSheet: View {
    let preview: ClueTile.Model?
    let subtitle: String
    let options: [BadgeOption]
    let onChoose: (ClueTag) -> Void
    let onCancel: () -> Void

    /// Measured from the card's top-right corner on the mockup canvas.
    private enum Metrics {
        static let cardSize = CGSize(width: 520, height: 262)
        static let previewTop: CGFloat = 20
        static let previewRightInset: CGFloat = 23
        static let titleCenterY: CGFloat = 46.5
        static let subtitleCenterY: CGFloat = 69.5
        static let textRightInset: CGFloat = 91
        static let optionsTop: CGFloat = 93
        static let optionSpacing: CGFloat = 9
        static let cancelCenterY: CGFloat = 222
    }

    var body: some View {
        ZStack {
            // 48% black dims the board. It's sized well past the canvas so it
            // also covers the edges of screens wider than the mockup; taps on
            // it do nothing.
            Color.black.opacity(0.48)
                .frame(width: GameLayout.canvasSize.width * 3, height: GameLayout.canvasSize.height * 3)
                .contentShape(Rectangle())
                .onTapGesture {}
                .accessibilityHidden(true)
            card
        }
    }

    private var card: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .circular)
        return ZStack(alignment: .topLeading) {
            if let preview {
                ClueTile(model: preview, style: .preview)
                    .padding(.top, Metrics.previewTop)
                    .padding(.leading, Metrics.previewRightInset)
            }
            Text(Strings.BadgePicker.title)
                .font(.titleScreen)
                .foregroundStyle(Color.black)
                .accessibilityAddTraits(.isHeader)
                .frame(height: 0)
                .padding(.top, Metrics.titleCenterY)
                .padding(.leading, Metrics.textRightInset)
            Text(subtitle)
                .font(.bodyRegular)
                .foregroundStyle(Color.black.opacity(0.55))
                .accessibilityIdentifier("game.picker.subtitle")
                .frame(height: 0)
                .padding(.top, Metrics.subtitleCenterY)
                .padding(.leading, Metrics.textRightInset)
            // Reading order: the "?" card is the physical right.
            HStack(spacing: Metrics.optionSpacing) {
                ForEach(options) { option in
                    BadgeOptionCard(tag: option.tag, caption: option.caption, isEnabled: option.isEnabled) {
                        onChoose(option.tag)
                    }
                    .accessibilityIdentifier("game.picker.option.\(option.tag)")
                }
            }
            .frame(width: Metrics.cardSize.width)
            .padding(.top, Metrics.optionsTop)
            Button(Strings.BadgePicker.cancel, action: onCancel)
                .buttonStyle(.appPickerCancel)
                .accessibilityIdentifier("game.picker.cancel")
                .frame(width: Metrics.cardSize.width, height: 0)
                .padding(.top, Metrics.cancelCenterY)
        }
        .frame(width: Metrics.cardSize.width, height: Metrics.cardSize.height, alignment: .topLeading)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 4))
        .hardShadow(in: shape, offset: CGSize(width: 6, height: 6))
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityIdentifier("game.picker")
    }
}
