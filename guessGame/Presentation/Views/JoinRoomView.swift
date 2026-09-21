import SwiftUI

/// Room-code entry pushed from Home's "انضم إلى غرفة" button: a four-box code
/// typed on a custom keypad, then one of three outcomes — still entering, a
/// rejected code (error banner), or a full room (result card in place of the
/// keypad). `JoinRoomViewModel` owns the entry rules and the state; this view
/// only lays them out.
///
/// Built to the landscape 852×393pt mockups. Surfaces that are white, yellow,
/// red or green in the mockups stay literal in Dark Mode (same precedent as
/// HomeSettingView), so text on them is literal; only text on Paper uses
/// `inkText`.
struct JoinRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: JoinRoomViewModel

    init(viewModel: JoinRoomViewModel = JoinRoomViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    private enum Metrics {
        static let codeColumnWidth: CGFloat = 298
        static let keypadSlotWidth: CGFloat = 396
        static let columnGap: CGFloat = 14
        static let contentWidth = keypadSlotWidth + columnGap + codeColumnWidth
        /// Extra space on the physical right of the content: puts its left edge
        /// at x=64 on the 852pt canvas (64pt margin left, 80pt right).
        static let rightBias: CGFloat = 16
        static let keypadTop: CGFloat = 32
        static let cardTop: CGFloat = 58
        static let cardLeadingInset: CGFloat = 7
        static let codeColumnTop: CGFloat = 76
        static let promptHeight: CGFloat = 21
        static let promptToBoxes: CGFloat = 12
        static let boxesToMessage: CGFloat = 19
        static let messageHeight: CGFloat = 40
        /// The boxes and caption are centered 5pt right of the prompt and
        /// banner, so they get 10pt of physical-left padding.
        static let boxesLeftInset: CGFloat = 10
        /// The content plus its right bias — the narrowest width that holds
        /// it at its measured position. iPhone 16 landscape gives 852 or its
        /// 734 safe-area width, both at least this, so the scale is exactly 1
        /// there; narrower screens (iPhone SE class) scale the content down
        /// uniformly instead of clipping it.
        static let fitReferenceWidth = contentWidth + rightBias
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: Strings.JoinRoom.title,
                backAccessibilityLabel: Strings.JoinRoom.backAccessibilityLabel,
                horizontalInset: 41,
                onBack: { dismiss() }
            )

            GeometryReader { geometry in
                content
                    .frame(width: geometry.size.width)
                    .scaleEffect(min(1, geometry.size.width / Metrics.fitReferenceWidth), anchor: .top)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.paper.ignoresSafeArea())
        // Box, key and card sizes are pixel-measured and fixed, so larger
        // Dynamic Type sizes would clip them.
        .dynamicTypeSize(.large)
        .navigationBarHidden(true)
        .onChange(of: viewModel.state) {
            if let message = viewModel.announcement {
                AccessibilityNotification.Announcement(message).post()
            }
        }
    }

    // MARK: - Content

    // The first child is the physical right under the app's forced RTL layout:
    // the code column sits right, the keypad (or the card) left.
    private var content: some View {
        HStack(alignment: .top, spacing: Metrics.columnGap) {
            codeColumn
            leftSlot
        }
        .frame(width: Metrics.contentWidth)
        .padding(.leading, Metrics.rightBias)
        .frame(maxWidth: .infinity)
    }

    private var codeColumn: some View {
        VStack(spacing: 0) {
            Text(Strings.JoinRoom.codePrompt)
                .font(.labelPrompt)
                .foregroundStyle(Color.inkText)
                .frame(maxWidth: .infinity)
                .frame(height: Metrics.promptHeight)
                .accessibilityAddTraits(.isHeader)

            CodeDigitRow(
                slots: viewModel.slots,
                boxLabel: { Strings.JoinRoom.boxLabel(position: $0 + 1, of: JoinRoomViewModel.codeLength) },
                emptyValue: Strings.JoinRoom.boxEmptyValue,
                identifierPrefix: "joinRoom.box"
            )
            .padding(.top, Metrics.promptToBoxes)
            .padding(.trailing, Metrics.boxesLeftInset)
            .frame(maxWidth: .infinity)

            message
                .frame(height: Metrics.messageHeight, alignment: .top)
                .padding(.top, Metrics.boxesToMessage)
        }
        .padding(.top, Metrics.codeColumnTop)
        .frame(width: Metrics.codeColumnWidth)
    }

    @ViewBuilder
    private var message: some View {
        switch viewModel.state {
        case .idle:
            Text(Strings.JoinRoom.codeCaption)
                .font(.bodyRegular)
                .foregroundStyle(Color.inkText.opacity(0.55))
                .frame(height: 16)
                .padding(.trailing, Metrics.boxesLeftInset)
        case .invalidCode:
            MessageBanner(text: Strings.JoinRoom.invalidCodeMessage)
                .accessibilityIdentifier("joinRoom.banner")
        case .roomFull:
            EmptyView()
        }
    }

    // One fixed-width slot so the code column never shifts between states;
    // trailing is the physical left under RTL.
    private var leftSlot: some View {
        Group {
            if case .roomFull(let capacity) = viewModel.state {
                AlertCard(
                    badge: Strings.JoinRoom.roomFullBadge(capacity: capacity),
                    title: Strings.JoinRoom.roomFullTitle,
                    subtitle: Strings.JoinRoom.roomFullSubtitle,
                    message: Strings.JoinRoom.roomFullMessage(capacity: capacity),
                    primaryTitle: Strings.JoinRoom.retryButton,
                    onPrimary: { viewModel.retry() },
                    secondaryTitle: Strings.JoinRoom.homeButton,
                    onSecondary: { dismiss() },
                    identifier: "joinRoom.card",
                    primaryIdentifier: "joinRoom.card.retry",
                    secondaryIdentifier: "joinRoom.card.home"
                )
                .padding(.top, Metrics.cardTop)
                .padding(.trailing, Metrics.cardLeadingInset)
            } else {
                NumericKeypad(
                    deleteTitle: Strings.JoinRoom.deleteKey,
                    confirmTitle: Strings.JoinRoom.confirmKey,
                    onDigit: { viewModel.appendDigit($0) },
                    onDelete: { viewModel.deleteLast() },
                    onConfirm: { viewModel.confirm() }
                )
                .padding(.top, Metrics.keypadTop)
            }
        }
        .frame(width: Metrics.keypadSlotWidth, alignment: .trailing)
    }
}

#Preview("Idle") {
    NavigationStack {
        JoinRoomView(viewModel: JoinRoomViewModel(code: "87"))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Invalid code") {
    NavigationStack {
        JoinRoomView(viewModel: JoinRoomViewModel(code: "8702", state: .invalidCode))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Room full") {
    NavigationStack {
        JoinRoomView(viewModel: JoinRoomViewModel(code: "8704", state: .roomFull(capacity: 6)))
    }
    .environment(\.layoutDirection, .rightToLeft)
}
