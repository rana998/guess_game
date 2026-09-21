import SwiftUI

/// The screen after a room code is accepted: pick a name and color for the
/// avatar (a live preview shows both), see who is already in the room, and
/// enter it. `EnterNameViewModel` owns the room and the choices; this view only
/// lays them out.
///
/// Built to the landscape 852×393pt mockup. Surfaces that are white, yellow or
/// green in the mockup stay literal in Dark Mode (same precedent as
/// HomeSettingView), so text on them is literal; nothing here sits directly on
/// Paper.
struct EnterNameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EnterNameViewModel
    @FocusState private var isNameFocused: Bool

    init(viewModel: EnterNameViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private enum Metrics {
        static let rightColumnWidth: CGFloat = 377
        static let cardWidth: CGFloat = 270
        static let columnGap: CGFloat = 89
        static let contentWidth = rightColumnWidth + columnGap + cardWidth
        /// Extra space on each side of the content. The centered block is
        /// `leftBias + content + rightMargin` wide, so it puts the content at
        /// x=75…811 on the 852pt canvas (75pt margin left, 41pt right — the
        /// back button's edge) as long as `leftBias − rightMargin` stays 34.
        /// The margin keeps the right column's shadows on screen when the
        /// block is scaled down to the screen's full width.
        static let leftBias: CGFloat = 50
        static let rightMargin: CGFloat = 16
        static let contentTop: CGFloat = 34
        static let badgeToField: CGFloat = 11
        static let fieldToSwatches: CGFloat = 20
        static let swatchesToSubmit: CGFloat = 36
        static let submitHeight: CGFloat = 56
        static let nameTextInset: CGFloat = 24
        /// The room-code pill's left edge and top, measured from the header
        /// bar's physical left and top.
        static let pillLeft: CGFloat = 66
        static let pillTop: CGFloat = 31
        /// iPhone 16 landscape gives this screen 852 or its 734 safe-area
        /// width. The content overflows the safe area on purpose (it is
        /// centered, so it lands at the same x either way), so 734 is the
        /// narrowest width that still needs no scaling.
        static let fitMinimumWidth: CGFloat = 734
        static let fitReferenceWidth = contentWidth + leftBias + rightMargin
    }

    /// 1 on every current notched iPhone in landscape; narrower screens (iPhone
    /// SE class) scale the content down uniformly instead of clipping it.
    static func fitScale(forWidth width: CGFloat) -> CGFloat {
        width >= Metrics.fitMinimumWidth ? 1 : width / Metrics.fitReferenceWidth
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: Strings.EnterName.title,
                backAccessibilityLabel: Strings.EnterName.backAccessibilityLabel,
                horizontalInset: 41,
                titleSpacing: 12.5,
                onBack: { dismiss() }
            ) {
                RoomCodePill(caption: Strings.EnterName.roomCaption, code: viewModel.roomCode)
                    .padding(.top, Metrics.pillTop)
                    // Trailing is the physical left under RTL.
                    .padding(.trailing, Metrics.pillLeft)
                    .accessibilityIdentifier("enterName.roomCode")
            }

            GeometryReader { geometry in
                content
                    .frame(width: geometry.size.width)
                    .scaleEffect(Self.fitScale(forWidth: geometry.size.width), anchor: .top)
            }
            .padding(.top, Metrics.contentTop)
        }
        .frame(maxWidth: .infinity)
        .background(Color.paper.ignoresSafeArea().onTapGesture { isNameFocused = false })
        // Field, swatch, button and card sizes are pixel-measured and fixed, so
        // larger Dynamic Type sizes would clip them.
        .dynamicTypeSize(.large)
        // The keyboard opens over the lower rows instead of shoving the layout up.
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
    }

    // MARK: - Content

    // The first child is the physical right under the app's forced RTL layout:
    // the name/color column sits right, the players card left.
    private var content: some View {
        HStack(alignment: .top, spacing: Metrics.columnGap) {
            nameColumn
            PlayersCard(
                title: Strings.EnterName.playersTitle,
                rows: viewModel.rows,
                footer: viewModel.playersCountText,
                identifierPrefix: "enterName"
            )
        }
        .frame(width: Metrics.contentWidth)
        // Trailing is the physical left under RTL.
        .padding(.trailing, Metrics.leftBias)
        .padding(.leading, Metrics.rightMargin)
        .frame(maxWidth: .infinity)
    }

    private var nameColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Metrics.badgeToField) {
                avatarPreview
                NameField(
                    text: Bindable(viewModel).name,
                    isFocused: $isNameFocused,
                    label: Strings.EnterName.nameFieldLabel,
                    placeholder: Strings.EnterName.namePlaceholder,
                    identifier: "enterName.nameField",
                    textInset: Metrics.nameTextInset
                )
            }

            ColorSwatchPicker(
                options: PlayerColor.allCases,
                selection: Bindable(viewModel).color,
                groupLabel: Strings.EnterName.avatarColorLabel,
                identifierPrefix: "enterName.swatch",
                color: \.color,
                optionLabel: \.accessibilityLabel
            )
            .padding(.top, Metrics.fieldToSwatches)

            Button(Strings.EnterName.submit) {
                if viewModel.canSubmit {
                    viewModel.submit()
                } else {
                    // Nothing to enter under yet: ask for the name instead.
                    isNameFocused = true
                }
            }
            .buttonStyle(.appPrimaryHeavy.sized(width: Metrics.rightColumnWidth, height: Metrics.submitHeight))
            .accessibilityIdentifier("enterName.submit")
            .padding(.top, Metrics.swatchesToSubmit)
        }
        .frame(width: Metrics.rightColumnWidth, alignment: .leading)
    }

    private var avatarPreview: some View {
        let initial = AvatarBadge.initial(from: viewModel.name, placeholder: Strings.EnterName.namePlaceholder)

        return AvatarBadge(initial: initial, color: viewModel.color.color, isDecorative: false)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Strings.EnterName.avatarPreviewLabel)
            .accessibilityValue(initial)
            .accessibilityIdentifier("enterName.avatar")
    }
}

#if DEBUG
#Preview("Mockup — 3 players") {
    NavigationStack {
        EnterNameView(viewModel: EnterNameViewModel(room: .sample(), color: .pink))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Name typed") {
    NavigationStack {
        EnterNameView(viewModel: EnterNameViewModel(room: .sample(), name: Strings.EnterName.namePlaceholder, color: .pink))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Only the owner") {
    NavigationStack {
        EnterNameView(viewModel: EnterNameViewModel(room: .sample(playerCount: 1)))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Six players (list scrolls)") {
    NavigationStack {
        EnterNameView(viewModel: EnterNameViewModel(room: .sample(playerCount: 6)))
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Empty room") {
    NavigationStack {
        EnterNameView(viewModel: EnterNameViewModel(room: .sample(playerCount: 0)))
    }
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
