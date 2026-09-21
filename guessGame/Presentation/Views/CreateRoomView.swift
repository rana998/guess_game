import SwiftUI

/// Room setup screen pushed from Home's "إنشاء غرفة" button: player name and
/// avatar color, player count, round duration, and the create button.
///
/// Built to the landscape 852×393pt mockup. UI-only for now — selections live
/// in local state and the create button does nothing until room logic exists
/// (see CLAUDE.md's Non-Goals). Surfaces that are white or green in the mockup
/// stay literal in Dark Mode (same precedent as HomeSettingView), so text on
/// them uses literal black; only text sitting on Paper uses `inkText`.
struct CreateRoomView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var avatarColor = AvatarColor.green
    @State private var playerCount = 6
    @State private var roundSeconds = 60
    @FocusState private var isNameFocused: Bool

    private enum Metrics {
        static let columnWidth: CGFloat = 724
        /// Extra space on the physical left of the column: shifts it 5pt right
        /// of the screen's center, to x=69…793 on the 852pt canvas (69pt margin
        /// on the left, 59pt on the right — the back button's outer edge).
        static let leftBias: CGFloat = 10
        static let contentTop: CGFloat = 17
        static let topRowSpacing: CGFloat = 16
        static let rowGap: CGFloat = 23
        static let groupGap: CGFloat = 35
        static let pillsToSubmit: CGFloat = 35
        static let captionTop: CGFloat = 35
        static let playerPillWidth: CGFloat = 76
        static let playerPillSpacing: CGFloat = 13
        static let durationPillWidth: CGFloat = 108
        static let durationPillSpacing: CGFloat = 11
        /// The column plus its left bias — the narrowest width that holds it at
        /// its measured position. That is also iPhone 16's landscape safe-area
        /// width (852 − 2×59), so the scale is exactly 1 whether or not this
        /// screen's container applies the safe area. Narrower screens (iPhone SE
        /// class) scale the column down uniformly instead of clipping it.
        static let fitReferenceWidth = columnWidth + leftBias
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: Strings.CreateRoom.title,
                backAccessibilityLabel: Strings.CreateRoom.backAccessibilityLabel,
                titleSpacing: 13,
                onBack: { dismiss() }
            )

            GeometryReader { geometry in
                content
                    .frame(width: geometry.size.width)
                    .scaleEffect(min(1, geometry.size.width / Metrics.fitReferenceWidth), anchor: .top)
            }
            .padding(.top, Metrics.contentTop)
        }
        .frame(maxWidth: .infinity)
        .background(Color.paper.ignoresSafeArea().onTapGesture { isNameFocused = false })
        // Card and line heights are pixel-measured and fixed, so larger
        // Dynamic Type sizes would clip them.
        .dynamicTypeSize(.large)
        // The keyboard opens over the pills instead of shoving the layout up.
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
    }

    // MARK: - Content

    // The HStacks list items in reading order: the first child is the
    // physical right under the app's forced RTL layout. `.leading` alignment
    // is the physical right too.
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            topRow

            HStack(alignment: .top, spacing: Metrics.groupGap) {
                SelectablePillGroup(
                    title: Strings.CreateRoom.durationTitle,
                    caption: Strings.CreateRoom.durationCaption,
                    values: [30, 60, 90],
                    selection: $roundSeconds,
                    pillWidth: Metrics.durationPillWidth,
                    pillSpacing: Metrics.durationPillSpacing,
                    identifierPrefix: "createRoom.duration"
                )
                SelectablePillGroup(
                    title: Strings.CreateRoom.playersTitle,
                    caption: Strings.CreateRoom.playersCaption,
                    values: [3, 4, 5, 6],
                    selection: $playerCount,
                    pillWidth: Metrics.playerPillWidth,
                    pillSpacing: Metrics.playerPillSpacing,
                    identifierPrefix: "createRoom.players"
                )
            }
            .padding(.top, Metrics.rowGap)

            bottomRow
                .padding(.top, Metrics.pillsToSubmit)
        }
        .frame(width: Metrics.columnWidth, alignment: .leading)
        .padding(.trailing, Metrics.leftBias)
        .frame(maxWidth: .infinity)
    }

    private var topRow: some View {
        HStack(spacing: Metrics.topRowSpacing) {
            AvatarBadge(
                initial: AvatarBadge.initial(from: name, placeholder: Strings.CreateRoom.namePlaceholder),
                color: avatarColor.color
            )
            nameField
            ColorSwatchPicker(
                options: AvatarColor.allCases,
                selection: $avatarColor,
                groupLabel: Strings.CreateRoom.avatarColorLabel,
                identifierPrefix: "createRoom.swatch",
                color: \.color,
                optionLabel: \.accessibilityLabel
            )
        }
    }

    private var nameField: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .circular)

        return TextField(
            Strings.CreateRoom.nameFieldLabel,
            text: $name,
            prompt: Text(Strings.CreateRoom.namePlaceholder).foregroundStyle(Color.black.opacity(0.5))
        )
        .font(.inputText)
        .foregroundStyle(Color.black)
        .tint(.brandRed)
        .multilineTextAlignment(.leading)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.done)
        .onSubmit { isNameFocused = false }
        .focused($isNameFocused)
        // Leading is the physical right under RTL, where the text starts.
        .padding(.leading, 18)
        // UITextField centers its line box a little low against the mockup's
        // ink (measured 0.7pt); this lifts the text by half the padding.
        .padding(.bottom, 1.5)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.inkStroke, lineWidth: 4))
        .hardShadow(in: shape, offset: CGSize(width: 4, height: 4))
        // The whole box focuses the field, not just the text's own frame.
        .contentShape(Rectangle())
        .onTapGesture { isNameFocused = true }
        .accessibilityIdentifier("createRoom.nameField")
    }

    private var bottomRow: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(Strings.CreateRoom.codeCaption)
                .font(.bodyRegular)
                .foregroundStyle(Color.inkText.opacity(0.55))
                .padding(.top, Metrics.captionTop)
            Spacer(minLength: 16)
            Button(Strings.CreateRoom.submit) {
                // No room logic exists yet; wired when the create-room use case lands.
            }
            .buttonStyle(.appPrimaryHeavy)
            .accessibilityIdentifier("createRoom.submit")
        }
    }
}

#Preview("iPhone 16 — Landscape", traits: .landscapeLeft) {
    NavigationStack {
        CreateRoomView()
    }
    .environment(\.layoutDirection, .rightToLeft)
}
