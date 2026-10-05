import SwiftUI

/// The describer's board: the secret word, the cube budget and the timer up
/// top, the tags' legend, and the 8×4 grid of placeholder images. Tapping an
/// untagged image opens the tag picker. Built to the 852×393 "Describer Board"
/// mockup.
struct DescriberBoardView: View {
    @State private var viewModel: DescriberBoardViewModel
    /// How far the grid is scrolled, for the custom scroll indicator.
    @State private var gridScrollOffset: CGFloat = 0
    let onBack: () -> Void

    init(viewModel: DescriberBoardViewModel, onBack: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
    }

    /// Measured on the mockup canvas.
    private enum Metrics {
        static let topBarHeight: CGFloat = 115
        static let controlsCenterY: CGFloat = 42.5
        /// The header row's physical right edge (the back button's).
        static let controlsRight: CGFloat = 811.5
        static let controlsWidth: CGFloat = 600
        static let controlSpacing: CGFloat = 8
        static let controlHeight: CGFloat = 44
        static let counterWidth: CGFloat = 84
        static let endRoundCenter = CGPoint(x: 105, y: 42.5)
        static let dashedRuleCenterY: CGFloat = 86
        static let legendCenterY: CGFloat = 102
        static let legendRight: CGFloat = 812
        static let legendItemSpacing: CGFloat = 10
        static let legendIconSpacing: CGFloat = 5
        static let gridTop: CGFloat = 118
        static let gridTopPadding: CGFloat = 17
        static let gridBottomPadding: CGFloat = 16
        static let columns = 8
        static let columnSpacing: CGFloat = 12
        static let rowSpacing: CGFloat = 8
        static let tileSide: CGFloat = 84
        static let indicatorCenterX: CGFloat = 38
        static let indicatorTop: CGFloat = 135
        static var gridViewportHeight: CGFloat { GameLayout.canvasSize.height - gridTop }
        static var gridContentHeight: CGFloat {
            let rowCount = CGFloat(Round.tileCount / columns)
            return gridTopPadding + rowCount * tileSide + (rowCount - 1) * rowSpacing + gridBottomPadding
        }
    }

    var body: some View {
        ZStack {
            GameCanvas(topBarHeight: Metrics.topBarHeight) {
                ZStack {
                    header
                    grid
                        .frame(width: GameLayout.canvasSize.width, height: Metrics.gridViewportHeight)
                        .canvasCenter(x: GameLayout.canvasSize.width / 2, y: Metrics.gridTop + Metrics.gridViewportHeight / 2)
                    scrollIndicator
                }
                .accessibilityHidden(viewModel.isPickerPresented)
                if viewModel.isPickerPresented {
                    BadgePickerSheet(
                        preview: viewModel.pickerPreview,
                        subtitle: viewModel.pickerSubtitle,
                        options: viewModel.pickerOptions,
                        onChoose: { tag in viewModel.choose(tag) },
                        onCancel: { viewModel.cancelPicker() }
                    )
                    .canvasCenter(x: GameLayout.canvasSize.width / 2, y: GameLayout.canvasSize.height / 2)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.screen.describerBoard")
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            controls
                .frame(width: Metrics.controlsWidth, alignment: .leading)
                .canvasCenter(x: Metrics.controlsRight - Metrics.controlsWidth / 2, y: Metrics.controlsCenterY)
            Button(Strings.DescriberBoard.endRound) { viewModel.endRound() }
                .buttonStyle(.appEndRound)
                .disabled(!viewModel.canEndRound)
                .opacity(viewModel.canEndRound ? 1 : 0.5)
                .accessibilityIdentifier("game.endRound")
                .canvasCenter(x: Metrics.endRoundCenter.x, y: Metrics.endRoundCenter.y)
            DashedRule()
                .frame(width: GameLayout.canvasSize.width)
                .canvasCenter(x: GameLayout.canvasSize.width / 2, y: Metrics.dashedRuleCenterY)
            legend
                .frame(width: Metrics.legendRight, alignment: .leading)
                .canvasCenter(x: Metrics.legendRight / 2, y: Metrics.legendCenterY)
        }
    }

    // Reading order: the back button is the physical right.
    private var controls: some View {
        HStack(spacing: Metrics.controlSpacing) {
            RoundedChevronButton(action: onBack)
                .accessibilityLabel(Strings.DescriberBoard.backAccessibilityLabel)
                .accessibilityIdentifier("game.back")
            wordPill
            detailCounter
            RoundCountdownPill(timerText: { viewModel.timerText })
        }
    }

    private var wordPill: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .circular)
        return HStack(spacing: 6) {
            Text(Strings.DescriberBoard.wordCaption)
                .font(.bodySmallStrong)
                .foregroundStyle(Color.black.opacity(0.5))
            Text(viewModel.wordText)
                .font(.labelSection)
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 6)
        .frame(height: Metrics.controlHeight)
        .background(Color.paper, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 3))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("game.wordPill")
    }

    private var detailCounter: some View {
        HStack(spacing: 6) {
            ClueTagIcon(tag: .detail, size: .counter)
            Text(viewModel.detailCounterText)
                .font(.counterMono)
                .foregroundStyle(Color.black)
        }
        .frame(width: Metrics.counterWidth, height: Metrics.controlHeight)
        .background(Color.white, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.black, lineWidth: 3))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Strings.DescriberBoard.detailCounterLabel)
        .accessibilityValue(viewModel.detailCounterText)
        .accessibilityIdentifier("game.detailCounter")
    }

    // Reading order: "?" first, at the physical right.
    private var legend: some View {
        HStack(spacing: Metrics.legendItemSpacing) {
            ForEach(ClueTag.allCases, id: \.self) { tag in
                HStack(spacing: Metrics.legendIconSpacing) {
                    ClueTagIcon(tag: tag, size: .legend)
                    Text(tag.title)
                        .font(.bodySmallStrong)
                        .foregroundStyle(Color.black)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Grid

    // Not lazy, so every tile exists for VoiceOver and UI tests even before it
    // scrolls into view. Reading order puts tile 0 at the top right.
    private var grid: some View {
        let tiles = viewModel.tiles
        let rows = stride(from: 0, to: tiles.count, by: Metrics.columns).map { rowStart in
            Array(tiles[rowStart..<min(rowStart + Metrics.columns, tiles.count)])
        }
        return ScrollView(.vertical) {
            VStack(spacing: Metrics.rowSpacing) {
                ForEach(rows, id: \.first?.id) { row in
                    HStack(spacing: Metrics.columnSpacing) {
                        ForEach(row) { tile in tileButton(tile) }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Metrics.gridTopPadding)
            .padding(.bottom, Metrics.gridBottomPadding)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named(Self.gridSpace)).minY)
                }
            }
        }
        .coordinateSpace(name: Self.gridSpace)
        .scrollIndicators(.hidden)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in gridScrollOffset = offset }
    }

    private static let gridSpace = "describerBoard.grid"

    // The mockup's own always-visible bar, in place of the system indicator.
    private var scrollIndicator: some View {
        let scrollableDistance = Metrics.gridContentHeight - Metrics.gridViewportHeight
        let trackHeight = GameLayout.canvasSize.height - Metrics.indicatorTop
        return BoardScrollIndicator(
            visibleFraction: Metrics.gridViewportHeight / Metrics.gridContentHeight,
            scrollProgress: scrollableDistance > 0 ? -gridScrollOffset / scrollableDistance : 0
        )
        .frame(height: trackHeight)
        .canvasCenter(x: Metrics.indicatorCenterX, y: Metrics.indicatorTop + trackHeight / 2)
    }

    private func tileButton(_ tile: ClueTile.Model) -> some View {
        Button {
            viewModel.selectTile(tile.id)
        } label: {
            ClueTile(model: tile, style: .board)
        }
        .buttonStyle(.appClueTile)
        .disabled(!viewModel.isTileEnabled(tile))
        .accessibilityLabel(tile.accessibilityLabel)
        .accessibilityValue(tile.accessibilityValue)
        .accessibilityHint(viewModel.isTileEnabled(tile) ? Strings.DescriberBoard.tileHint : "")
        .accessibilityIdentifier("game.tile.\(tile.id)")
    }
}

#if DEBUG
#Preview("Describer board", traits: .landscapeLeft) {
    DescriberBoardView(
        viewModel: DescriberBoardViewModel(
            useCases: .preview(seededWith: .sample(phase: .describing, marks: [
                ClueMark(tileIndex: 5, tag: .detail),
                ClueMark(tileIndex: 14, tag: .secondaryIdea),
                ClueMark(tileIndex: 19, tag: .mainIdea),
            ])),
            viewerId: "lobby-0",
            clock: GameClock(currentDate: { Game.sampleNow })
        ),
        onBack: {}
    )
}
#endif
