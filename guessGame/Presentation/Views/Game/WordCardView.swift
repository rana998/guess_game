import SwiftUI

/// The describer's secret word on a comic burst, the three tags they'll
/// describe it with, and "ابدأ الوصف", which starts the timer. Built to the
/// 852×393 "WordCard" mockup.
struct WordCardView: View {
    @State private var viewModel: WordCardViewModel

    init(viewModel: WordCardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// Centers and sizes measured on the mockup canvas.
    private enum Metrics {
        static let burstCenter = CGPoint(x: 621.5, y: 196)
        static let burstSize = CGSize(width: 364, height: 283)
        static let cardCenter = CGPoint(x: 622.5, y: 197)
        static let titleCenter = CGPoint(x: 281.5, y: 91)
        static let checklistCenter = CGPoint(x: 230.5, y: 184.5)
        static let checklistSize = CGSize(width: 246, height: 124)
        /// Row centers from the checklist's top edge, and the icon column's
        /// distance from its right edge.
        static let ruleRowCenters: [CGFloat] = [29, 62, 94]
        static let iconColumnWidth: CGFloat = 30
        static let iconColumnInset: CGFloat = 12
        static let startCenter = CGPoint(x: 226.5, y: 289.5)
        static let startSize = CGSize(width: 242, height: 56)
    }

    var body: some View {
        GameCanvas {
            ZStack {
                burst
                    .canvasCenter(x: Metrics.burstCenter.x, y: Metrics.burstCenter.y)
                SecretWordCard(word: viewModel.wordText, chipText: viewModel.chipText)
                    .canvasCenter(x: Metrics.cardCenter.x, y: Metrics.cardCenter.y)
                Text(Strings.WordCard.title)
                    .font(.titleLarge)
                    .foregroundStyle(Color.black)
                    .accessibilityAddTraits(.isHeader)
                    .canvasCenter(x: Metrics.titleCenter.x, y: Metrics.titleCenter.y)
                checklist
                    .canvasCenter(x: Metrics.checklistCenter.x, y: Metrics.checklistCenter.y)
                Button(Strings.WordCard.start) { viewModel.startDescribing() }
                    .buttonStyle(.appGameAction(fill: .brandLime, width: Metrics.startSize.width, height: Metrics.startSize.height))
                    .accessibilityIdentifier("game.startDescribing")
                    .canvasCenter(x: Metrics.startCenter.x, y: Metrics.startCenter.y)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.screen.wordCard")
    }

    private var burst: some View {
        let shape = BurstShape(pointCount: 14, innerRadiusRatio: 0.62, inset: 2)
        return ZStack {
            shape.fill(Color.brandYellow)
            shape.stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineJoin: .miter))
        }
        .frame(width: Metrics.burstSize.width, height: Metrics.burstSize.height)
        .accessibilityHidden(true)
    }

    private var checklist: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .circular)
        return ZStack(alignment: .top) {
            shape.fill(Color.white)
            // 38% black is the mockup's dashed outline; padding keeps the 4pt
            // line inside the frame, as DashedRoundedRect isn't insettable.
            DashedRoundedRect(cornerRadius: 16)
                .stroke(Color.black.opacity(0.38), style: StrokeStyle(lineWidth: 4, dash: [12, 8]))
                .padding(2)
            ForEach(Array(ClueTag.allCases.enumerated()), id: \.element) { position, tag in
                ruleRow(for: tag)
                    .frame(height: 0)
                    .padding(.top, Metrics.ruleRowCenters[position])
            }
        }
        .frame(width: Metrics.checklistSize.width, height: Metrics.checklistSize.height)
        .accessibilityElement(children: .combine)
    }

    // Reading order: the icon is the physical right.
    private func ruleRow(for tag: ClueTag) -> some View {
        HStack(spacing: 7) {
            ClueTagIcon(tag: tag)
                .frame(width: Metrics.iconColumnWidth)
            // The mockup sets its longest line a point smaller to fit the card.
            Text(viewModel.ruleText(for: tag))
                .font(.bodySmallStrong)
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            Spacer(minLength: 0)
        }
        .padding(.leading, Metrics.iconColumnInset)
    }
}

#if DEBUG
#Preview("Word card", traits: .landscapeLeft) {
    WordCardView(viewModel: WordCardViewModel(
        useCases: .preview(seededWith: .sample(phase: .wordDrawn)),
        viewerId: "lobby-0",
        clock: GameClock(currentDate: { Game.sampleNow })
    ))
}
#endif
