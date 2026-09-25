import SwiftUI

/// The lobby after creating or entering a room, for both roles: the room code,
/// a card per player (and an empty seat up to capacity), who is ready, and the
/// footer action. The owner copies the code, removes players, picks the round
/// length and starts the game; a participant toggles ready or leaves through
/// the kebab menu. `WaitingRoomViewModel` owns every rule; this view only lays
/// them out.
///
/// Built to the landscape 852×393pt owner and participant mockups, laid out on
/// the physical screen (it ignores the safe area, like Home.png). Cards and the
/// header/footer bars are literal white or yellow in both appearances, so text
/// on them is literal black; only the empty seats sit on Paper and use `inkText`.
struct WaitingRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WaitingRoomViewModel

    init(viewModel: WaitingRoomViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private enum Metrics {
        static let cardWidth: CGFloat = 242
        static let columns = 3
        static let columnGap: CGFloat = 10
        static let rowGap: CGFloat = 8
        /// Three cards and two gaps: x=53…799 on the 852pt canvas.
        static let gridWidth = CGFloat(columns) * cardWidth + CGFloat(columns - 1) * columnGap
        static let gridTop: CGFloat = 15
        static let footerHeight: CGFloat = 73
        static let footerRuleHeight: CGFloat = 3
        static let footerButtonTop: CGFloat = 9
        static let titleSpacing: CGFloat = 12
        /// The header accessory's distance from the physical left edge.
        static let headerLeft: CGFloat = 53
        static let headerButtonTop: CGFloat = 20
        /// The room pill's top and its gap to the copy chip (owner) or the
        /// kebab (participant), measured per mockup.
        static let ownerPillTop: CGFloat = 23
        static let ownerPillGap: CGFloat = 15
        static let participantPillTop: CGFloat = 25
        static let participantPillGap: CGFloat = 17
        /// Owner footer: the pills' top (y=333), count → divider → label → pills.
        static let ownerRowTop: CGFloat = 13
        static let countToDivider: CGFloat = 7
        static let dividerToLabel: CGFloat = 5.5
        static let labelToPills: CGFloat = 12
        static let durationPillWidth: CGFloat = 49
        static let durationPillSpacing: CGFloat = 16
        /// Participant footer: count over caption.
        static let participantTextTop: CGFloat = 17.5
        static let participantTextSpacing: CGFloat = 7
        /// The grid plus 16pt on each side.
        static let fitReferenceWidth = gridWidth + 32
    }

    /// 1 on every current notched iPhone in landscape; narrower screens (iPhone
    /// SE class) scale the grid and footer down uniformly instead of clipping.
    static func fitScale(forWidth width: CGFloat) -> CGFloat {
        width >= Metrics.fitReferenceWidth ? 1 : width / Metrics.fitReferenceWidth
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: Strings.WaitingRoom.title,
                backAccessibilityLabel: Strings.WaitingRoom.backAccessibilityLabel,
                titleSpacing: Metrics.titleSpacing,
                onBack: { dismiss() }
            ) {
                headerAccessory
            }

            // The Paper band takes whatever height is left (229 on iPhone 16).
            GeometryReader { geometry in
                grid
                    .frame(width: geometry.size.width)
                    .scaleEffect(Self.fitScale(forWidth: geometry.size.width), anchor: .top)
            }
            .padding(.top, Metrics.gridTop)
            .background(Color.paper)

            Color.black
                .frame(height: Metrics.footerRuleHeight)

            GeometryReader { geometry in
                footer
                    .frame(width: geometry.size.width, height: Metrics.footerHeight)
                    .scaleEffect(Self.fitScale(forWidth: geometry.size.width), anchor: .center)
            }
            .frame(height: Metrics.footerHeight)
            .background(Color.white)
        }
        // Laid out on the physical screen like the mockup: the header starts at
        // y=0 and the footer runs to the bottom edge. The 746pt grid is also
        // wider than iPhone 16's 734pt landscape safe area.
        .ignoresSafeArea()
        // Card, pill and bar sizes are pixel-measured and fixed, so larger
        // Dynamic Type sizes would clip them.
        .dynamicTypeSize(.large)
        .navigationBarHidden(true)
        .task(id: viewModel.copyConfirmationToken) {
            let token = viewModel.copyConfirmationToken
            guard token > 0 else { return }
            try? await Task.sleep(for: .seconds(1.5))
            // A newer copy restarts this task (and bumps the token), so a stale
            // timer can't hide the newer confirmation.
            viewModel.clearCopyConfirmation(token: token)
        }
        .onChange(of: viewModel.phase) { _, phase in
            if phase == .starting {
                AccessibilityNotification.Announcement(Strings.WaitingRoom.startingGame).post()
            }
        }
    }

    // MARK: - Header

    // Reading order: the room pill is first, so it sits at the physical right
    // of the copy chip or kebab.
    private var headerAccessory: some View {
        HStack(alignment: .top, spacing: viewModel.isOwner ? Metrics.ownerPillGap : Metrics.participantPillGap) {
            RoomCodePill(caption: Strings.WaitingRoom.roomCaption, code: viewModel.roomCode)
                .padding(.top, viewModel.isOwner ? Metrics.ownerPillTop : Metrics.participantPillTop)
                .accessibilityIdentifier("waitingRoom.roomCode")

            Group {
                if viewModel.isOwner {
                    CopyCodeButton(isConfirmed: viewModel.isShowingCopyConfirmation) {
                        viewModel.copyRoomCode()
                        AccessibilityNotification.Announcement(Strings.WaitingRoom.copied).post()
                    }
                } else {
                    KebabMenuButton(
                        accessibilityLabel: Strings.WaitingRoom.moreAccessibilityLabel,
                        leaveTitle: Strings.WaitingRoom.leaveRoom,
                        onLeave: { viewModel.leaveRoom() }
                    )
                }
            }
            .padding(.top, Metrics.headerButtonTop)
        }
        // Trailing is the physical left under RTL.
        .padding(.trailing, Metrics.headerLeft)
    }

    // MARK: - Grid

    // Leading is the physical right, so a partial last row starts on the right.
    private var grid: some View {
        VStack(spacing: Metrics.rowGap) {
            ForEach(Array(Self.rows(of: viewModel.slots).enumerated()), id: \.offset) { _, row in
                HStack(spacing: Metrics.columnGap) {
                    ForEach(row) { slotView($0) }
                }
                .frame(width: Metrics.gridWidth, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func slotView(_ slot: WaitingRoomSlot) -> some View {
        switch slot {
        case .player(let model):
            PlayerWaitingCard(
                model: model,
                isRemoveEnabled: !viewModel.isStarting,
                onRemove: { viewModel.removePlayer(id: model.id) }
            )
        case .empty:
            EmptyPlayerSlotCard()
        }
    }

    private static func rows(of slots: [WaitingRoomSlot]) -> [[WaitingRoomSlot]] {
        stride(from: 0, to: slots.count, by: Metrics.columns).map {
            Array(slots[$0..<min($0 + Metrics.columns, slots.count)])
        }
    }

    // MARK: - Footer

    // Reading order: the text block is the physical right, the button the left.
    private var footer: some View {
        HStack(alignment: .center, spacing: 0) {
            if viewModel.isOwner {
                ownerStatus
            } else {
                participantStatus
            }
            Spacer(minLength: 16)
            footerButton
                .padding(.top, Metrics.footerButtonTop)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(width: Metrics.gridWidth)
    }

    private var readyCount: some View {
        Text(viewModel.readyCountText)
            .font(.labelSection)
            .foregroundStyle(Color.black)
            .accessibilityIdentifier("waitingRoom.readyCount")
    }

    // One row centred on the duration pills. Leading paddings are the
    // physical right under RTL.
    private var ownerStatus: some View {
        HStack(alignment: .center, spacing: 0) {
            readyCount
            Color.black.opacity(0.15)
                .frame(width: 2, height: 26)
                .padding(.leading, Metrics.countToDivider)
                .padding(.trailing, Metrics.dividerToLabel)
                .accessibilityHidden(true)
            Text(Strings.WaitingRoom.durationTitle)
                .font(.labelSection)
                .foregroundStyle(Color.black)
                .accessibilityAddTraits(.isHeader)
            SelectablePillGroup(
                title: nil,
                caption: nil,
                values: Room.roundSecondsOptions,
                selection: Binding(get: { viewModel.roundSeconds }, set: { viewModel.setRoundSeconds($0) }),
                pillWidth: Metrics.durationPillWidth,
                pillSpacing: Metrics.durationPillSpacing,
                identifierPrefix: "waitingRoom.duration",
                size: .compact
            )
            .padding(.leading, Metrics.labelToPills)
            .disabled(viewModel.isStarting)
            .opacity(viewModel.isStarting ? 0.5 : 1)
        }
        .padding(.top, Metrics.ownerRowTop)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var participantStatus: some View {
        VStack(alignment: .leading, spacing: Metrics.participantTextSpacing) {
            readyCount
            Text(viewModel.participantCaption)
                .font(.bodySmallStrong)
                .foregroundStyle(Color.black.opacity(0.5))
        }
        .padding(.top, Metrics.participantTextTop)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var footerButton: some View {
        if viewModel.isOwner {
            Button(viewModel.startButtonTitle) { viewModel.startGame() }
                .buttonStyle(.appLobbyAction(fill: .brandLime))
                .disabled(!viewModel.canStart)
                .opacity(viewModel.canStart ? 1 : 0.5)
                .accessibilityHint(viewModel.hasEnoughPlayers ? "" : Strings.WaitingRoom.startHint)
                .accessibilityIdentifier("waitingRoom.start")
        } else {
            Button(viewModel.readyToggleTitle) { viewModel.toggleReady() }
                .buttonStyle(.appLobbyAction(fill: viewModel.isCurrentPlayerReady ? .white : .brandLime))
                .disabled(viewModel.isStarting)
                .opacity(viewModel.isStarting ? 0.5 : 1)
                .accessibilityIdentifier("waitingRoom.readyToggle")
        }
    }
}

#if DEBUG
#Preview("Owner", traits: .landscapeLeft) {
    NavigationStack {
        WaitingRoomView(viewModel: WaitingRoomViewModel(
            session: WaitingRoomSession(room: .sampleLobby(), role: .owner, currentPlayerId: "lobby-0"),
            copyToPasteboard: { _ in }
        ))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Participant", traits: .landscapeLeft) {
    NavigationStack {
        WaitingRoomView(viewModel: WaitingRoomViewModel(
            session: WaitingRoomSession(room: .sampleLobby(), role: .participant, currentPlayerId: "lobby-3"),
            copyToPasteboard: { _ in }
        ))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Owner, 2 of 4 (start disabled, empty slots)", traits: .landscapeLeft) {
    var room = Room.sampleLobby(capacity: 4)
    room.players = Array(room.players.prefix(2))
    return NavigationStack {
        WaitingRoomView(viewModel: WaitingRoomViewModel(
            session: WaitingRoomSession(room: room, role: .owner, currentPlayerId: "lobby-0"),
            copyToPasteboard: { _ in }
        ))
    }
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
