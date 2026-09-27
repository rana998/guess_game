import SwiftUI

/// A guesser's round screen: the round, timer and players up top; everyone's
/// guesses and the guess field on the left; the describer's images arriving
/// in the green main-idea box and the red secondary-idea box. Built to the
/// 852×393 "GuesserEmpty" (no images yet) and "Guesser Screen" mockups.
struct GuesserBoardView: View {
    @State private var viewModel: GuesserBoardViewModel
    @FocusState private var isGuessFieldFocused: Bool
    let onBack: () -> Void

    init(viewModel: GuesserBoardViewModel, onBack: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
    }

    /// Measured on the mockup canvas.
    private enum Metrics {
        static let topBarHeight: CGFloat = 85
        static let backCenter = CGPoint(x: 789.5, y: 39.5)
        static let roundPillCenter = CGPoint(x: 716.5, y: 42.5)
        static let roundPillSize = CGSize(width: 76, height: 36)
        static let timerCenter = CGPoint(x: 621.5, y: 40.5)
        static let stripRight: CGFloat = 341.5
        static let stripWidth: CGFloat = 320
        static let stripCenterY: CGFloat = 42.5
        static let avatarSpacing: CGFloat = 4

        static let panelCenter = CGPoint(x: 183, y: 237)
        static let panelSize = CGSize(width: 282, height: 276)
        static let listHeight: CGFloat = 207
        static let listTopInset: CGFloat = 16
        static let rowSpacing: CGFloat = 4
        static let emptyTitleY: CGFloat = 94.5
        static let emptySubtitleY: CGFloat = 123.5
        static let inputTop: CGFloat = 221
        static let fieldSize = CGSize(width: 191, height: 44)
        static let fieldToSend: CGFloat = 9

        static let mainBoxCenter = CGPoint(x: 575.5, y: 170)
        static let mainBoxSize = CGSize(width: 469, height: 134)
        static let boxHeaderCenterY: CGFloat = 18
        static let boxHeaderRightInset: CGFloat = 20
        static let mainCaptionLeftInset: CGFloat = 14
        static let slotsTop: CGFloat = 38
        static let slotSpacing: CGFloat = 6
        static let slotsRightInset: CGFloat = 13
        static let slotsLeftInset: CGFloat = 11

        static let secondaryBoxCenter = CGPoint(x: 575.5, y: 307.5)
        static let secondaryBoxSize = CGSize(width: 469, height: 131)
        static let secondaryTileTop: CGFloat = 36
        static let secondaryTileRightInset: CGFloat = 33
        static let secondaryCaptionGap: CGFloat = 17
        static let placeholderCenter = CGPoint(x: 575.5, y: 272)
        static let placeholderSize = CGSize(width: 468, height: 45)
        static let placeholderIconInset: CGFloat = 22

        static let bottomCaptionRight: CGFloat = 809
        static let bottomCaptionY: CGFloat = 374.5
    }

    var body: some View {
        GameCanvas(topBarHeight: Metrics.topBarHeight, contentAlignment: isGuessFieldFocused ? .bottom : .top) {
            ZStack {
                // Tapping outside the field puts the keyboard away.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { isGuessFieldFocused = false }
                header
                guessPanel
                    .canvasCenter(x: Metrics.panelCenter.x, y: Metrics.panelCenter.y)
                mainIdeaBox
                    .canvasCenter(x: Metrics.mainBoxCenter.x, y: Metrics.mainBoxCenter.y)
                secondaryIdea
                if let bottomCaption = viewModel.bottomCaption {
                    Text(bottomCaption)
                        .font(.bodySmall)
                        .foregroundStyle(Color.black.opacity(0.5))
                        .accessibilityIdentifier("game.bottomCaption")
                        .frame(width: Metrics.bottomCaptionRight, alignment: .leading)
                        .canvasCenter(x: Metrics.bottomCaptionRight / 2, y: Metrics.bottomCaptionY)
                }
            }
        }
        .onChange(of: viewModel.isRoundOver) { _, isOver in
            if isOver { isGuessFieldFocused = false }
        }
        .onChange(of: viewModel.markCount) { _, _ in
            if let announcement = viewModel.latestMarkAnnouncement {
                AccessibilityNotification.Announcement(announcement).post()
            }
        }
        .onChange(of: viewModel.guessCount) { _, _ in
            if let announcement = viewModel.latestGuessAnnouncement {
                AccessibilityNotification.Announcement(announcement).post()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.screen.guesserBoard")
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            RoundedChevronButton(action: onBack)
                .accessibilityLabel(Strings.DescriberBoard.backAccessibilityLabel)
                .accessibilityIdentifier("game.back")
                .canvasCenter(x: Metrics.backCenter.x, y: Metrics.backCenter.y)
            Text(viewModel.roundText)
                .font(.labelSection)
                .foregroundStyle(Color.white)
                .frame(width: Metrics.roundPillSize.width, height: Metrics.roundPillSize.height)
                .background(Color.black, in: Capsule())
                .accessibilityIdentifier("game.roundPill")
                .canvasCenter(x: Metrics.roundPillCenter.x, y: Metrics.roundPillCenter.y)
            RoundCountdownPill(timerText: { viewModel.timerText })
                .canvasCenter(x: Metrics.timerCenter.x, y: Metrics.timerCenter.y)
            playerStrip
                .frame(width: Metrics.stripWidth, alignment: .leading)
                .canvasCenter(x: Metrics.stripRight - Metrics.stripWidth / 2, y: Metrics.stripCenterY)
        }
    }

    // Reading order: who's describing, a divider, then the guessers.
    private var playerStrip: some View {
        HStack(spacing: 6) {
            if let describer = viewModel.describerAvatar {
                AvatarLabelCapsule(
                    avatar: describer,
                    text: Strings.GuesserBoard.describingNow,
                    fill: .brandLime,
                    textColor: .black,
                    font: .messageBanner,
                    borderWidth: 3,
                    height: 38,
                    avatarInset: 4,
                    avatarSpacing: 4,
                    textInset: 8
                )
                .accessibilityIdentifier("game.describerCapsule")
            }
            // 15% black is the mockup's hairline between describer and guessers.
            Color.black.opacity(0.15)
                .frame(width: 2, height: 26)
            HStack(spacing: Metrics.avatarSpacing) {
                ForEach(viewModel.guesserAvatars) { avatar in
                    AvatarBadge(initial: avatar.initial, color: avatar.color.color, size: .strip)
                }
            }
            .padding(.leading, -1)
            .accessibilityHidden(true)
        }
    }

    // MARK: - Guess panel

    private var guessPanel: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .circular)
        return VStack(spacing: 0) {
            guessList
                .frame(height: Metrics.listHeight)
            Color.black
                .frame(height: 3)
            inputBar
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, Metrics.inputTop - Metrics.listHeight - 3 - 3)
        }
        .padding(.top, 3)
        .frame(width: Metrics.panelSize.width, height: Metrics.panelSize.height)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 3))
        .hardShadow(in: shape, offset: CGSize(width: 3, height: 3))
    }

    @ViewBuilder
    private var guessList: some View {
        if viewModel.isGuessListEmpty {
            ZStack(alignment: .top) {
                Text(Strings.GuesserBoard.emptyTitle)
                    .font(.labelSection)
                    .foregroundStyle(Color.black)
                    .frame(height: 0)
                    .padding(.top, Metrics.emptyTitleY)
                Text(viewModel.emptySubtitle)
                    .font(.bodySmall)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .frame(height: 0)
                    .padding(.top, Metrics.emptySubtitleY)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("game.guessList.empty")
        } else {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(spacing: Metrics.rowSpacing) {
                        ForEach(viewModel.guessRows) { row in
                            GuessRow(model: row)
                                .id(row.id)
                                .accessibilityIdentifier("game.guessRow.\(row.id)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Metrics.listTopInset - 3)
                    .padding(.bottom, 8)
                }
                .scrollIndicators(.hidden)
                .onChange(of: viewModel.lastGuessId) { _, lastGuessId in
                    guard let lastGuessId else { return }
                    withAnimation { proxy.scrollTo(lastGuessId, anchor: .bottom) }
                }
                .onAppear {
                    if let lastGuessId = viewModel.lastGuessId { proxy.scrollTo(lastGuessId, anchor: .bottom) }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("game.guessList")
        }
    }

    // Reading order: the field is the physical right, send the left.
    private var inputBar: some View {
        let fieldShape = RoundedRectangle(cornerRadius: 12, style: .circular)
        return HStack(spacing: Metrics.fieldToSend) {
            TextField(
                "",
                text: $viewModel.draft,
                prompt: Text(Strings.GuesserBoard.placeholder).font(.bodyRegular).foregroundStyle(Color.black.opacity(0.5))
            )
            .font(.labelSection)
            .foregroundStyle(Color.black)
            .tint(Color.brandRed)
            .focused($isGuessFieldFocused)
            .submitLabel(.send)
            .onSubmit {
                viewModel.submit()
                // Return would otherwise put the keyboard away between guesses.
                isGuessFieldFocused = !viewModel.isRoundOver
            }
            .padding(.horizontal, 12)
            .frame(width: Metrics.fieldSize.width, height: Metrics.fieldSize.height)
            .background(Color.paper, in: fieldShape)
            .overlay(fieldShape.strokeBorder(Color.black, lineWidth: 2))
            .accessibilityIdentifier("game.guessField")
            Button {
                viewModel.submit()
            } label: {
                ChevronShape()
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .frame(width: 7, height: 14)
                    // Points left, toward where the guess goes in the list.
                    .rotationEffect(.degrees(180))
            }
            .buttonStyle(.appSend)
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1 : 0.5)
            .accessibilityLabel(Strings.GuesserBoard.send)
            .accessibilityIdentifier("game.sendGuess")
        }
    }

    // MARK: - Clue boxes

    private var mainIdeaBox: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .circular)
        return ZStack(alignment: .topLeading) {
            boxHeader(tag: .mainIdea)
            if let caption = viewModel.mainBoxCaption {
                Text(caption)
                    .font(.bodyRegular)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .accessibilityIdentifier("game.mainIdeaCaption")
                    .frame(width: Metrics.mainBoxSize.width - Metrics.mainCaptionLeftInset, height: 0, alignment: .trailing)
                    .padding(.top, Metrics.boxHeaderCenterY + 1)
            }
            mainSlots
                .padding(.top, Metrics.slotsTop)
        }
        .frame(width: Metrics.mainBoxSize.width, height: Metrics.mainBoxSize.height, alignment: .topLeading)
        .background(Color.tintLime, in: shape)
        .overlay(shape.strokeBorder(Color.brandLime, lineWidth: 4))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.mainIdeaBox")
    }

    // Five places show at a time; past five the row scrolls sideways, never wraps.
    private var mainSlots: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: Metrics.slotSpacing) {
                    ForEach(Array(viewModel.mainSlots.enumerated()), id: \.element.id) { position, slot in
                        ClueTile(model: slot, style: .mainIdea)
                            .id(slot.id)
                            .accessibilityIdentifier("game.mainSlot.\(position)")
                    }
                    ForEach(0..<viewModel.placeholderSlotCount, id: \.self) { _ in
                        EmptyClueSlot()
                    }
                }
                .padding(.leading, Metrics.slotsRightInset)
                .padding(.trailing, Metrics.slotsLeftInset)
                // Room for the tiles' hard shadows below them.
                .padding(.bottom, 4)
            }
            .scrollIndicators(.hidden)
            .frame(width: Metrics.mainBoxSize.width)
            .onChange(of: viewModel.lastMainSlotId) { _, lastSlotId in
                guard let lastSlotId else { return }
                withAnimation { proxy.scrollTo(lastSlotId, anchor: .trailing) }
            }
        }
    }

    @ViewBuilder
    private var secondaryIdea: some View {
        if let tile = viewModel.secondaryTile {
            secondaryIdeaBox(tile: tile)
                .canvasCenter(x: Metrics.secondaryBoxCenter.x, y: Metrics.secondaryBoxCenter.y)
        } else {
            secondaryPlaceholder
                .canvasCenter(x: Metrics.placeholderCenter.x, y: Metrics.placeholderCenter.y)
        }
    }

    private func secondaryIdeaBox(tile: ClueTile.Model) -> some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .circular)
        return ZStack(alignment: .topLeading) {
            boxHeader(tag: .secondaryIdea)
            // Reading order: the tile is the physical right, its caption to the left.
            HStack(spacing: Metrics.secondaryCaptionGap) {
                ClueTile(model: tile, style: .secondaryIdea)
                    .accessibilityIdentifier("game.secondarySlot")
                Text(Strings.GuesserBoard.secondaryCaption)
                    .font(.bodyRegular)
                    .foregroundStyle(Color.black.opacity(0.55))
            }
            .padding(.leading, Metrics.secondaryTileRightInset)
            .padding(.top, Metrics.secondaryTileTop)
        }
        .frame(width: Metrics.secondaryBoxSize.width, height: Metrics.secondaryBoxSize.height, alignment: .topLeading)
        .background(Color.tintRed, in: shape)
        .overlay(shape.strokeBorder(Color.brandRed, lineWidth: 4))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("game.secondaryIdeaBox")
    }

    private var secondaryPlaceholder: some View {
        HStack(spacing: 10) {
            ClueTagIcon(tag: .secondaryIdea, size: .counter)
            Text(Strings.GuesserBoard.secondaryPlaceholder)
                .font(.bodyRegular)
                .foregroundStyle(Color.black.opacity(0.6))
            Spacer(minLength: 0)
        }
        .padding(.leading, Metrics.placeholderIconInset)
        .frame(width: Metrics.placeholderSize.width, height: Metrics.placeholderSize.height)
        .background(Color.white, in: Capsule())
        // 40% black is the mockup's dashed outline.
        .overlay(Capsule().strokeBorder(Color.black.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("game.secondaryIdeaPlaceholder")
    }

    // Reading order: the tag's icon, then its name, from the box's physical right.
    private func boxHeader(tag: ClueTag) -> some View {
        HStack(spacing: 4) {
            ClueTagIcon(tag: tag, size: .counter)
            Text(tag.title)
                .font(.messageBanner)
                .foregroundStyle(Color.black)
        }
        .accessibilityAddTraits(.isHeader)
        .frame(height: 0)
        .padding(.top, Metrics.boxHeaderCenterY)
        .padding(.leading, Metrics.boxHeaderRightInset)
    }
}

#if DEBUG
#Preview("Guesser, no images yet", traits: .landscapeLeft) {
    GuesserBoardView(
        viewModel: GuesserBoardViewModel(
            useCases: .preview(seededWith: .sample(phase: .describing)),
            viewerId: "lobby-3",
            clock: GameClock(currentDate: { Game.sampleNow })
        ),
        onBack: {}
    )
}
#endif
