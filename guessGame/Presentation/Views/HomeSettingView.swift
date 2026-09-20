import SwiftUI

/// Settings screen pushed from Home's "..." button. Three UI-only toggle rows
/// (sound effects, music, vibration) plus a "How to Play" entry point.
///
/// Built to the landscape 852×393pt Figma spec. Surfaces that are white in the
/// spec (header, card) stay literally white in Dark Mode, so the text and
/// strokes on them use literal black rather than the InkText token.
struct HomeSettingView: View {
    @Environment(\.dismiss) private var dismiss

    // UI-only state for now — no persistence/backend wiring yet, matching
    // CLAUDE.md's "Non-Goals" phasing for this project.
    @State private var isSoundEffectsOn = true
    @State private var isMusicOn = false
    @State private var isVibrationOn = true

    private let contentWidth: CGFloat = 470
    private let cardHeight: CGFloat = 186

    var body: some View {
        VStack(spacing: 0) {
            header
            Color.black
                .frame(height: 3)
                .ignoresSafeArea(edges: .horizontal)

            settingsCard
                .padding(.top, 14)
            howToPlayButton
                .padding(.top, 15)
            footer
                .padding(.top, 15)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        // First child sits on the right under the app's forced RTL layout.
        HStack(spacing: 6) {
            RoundedChevronButton(action: { dismiss() })
                .accessibilityLabel(Strings.HomeSetting.backAccessibilityLabel)
            Text(Strings.HomeSetting.title)
                .font(.titleScreen)
                .foregroundStyle(Color.black)
            Spacer(minLength: 0)
        }
        // Measured from the physical screen edge (59pt, which is where iPhone
        // 16's landscape safe area ends), so the header lets its content run
        // past the safe area instead of stacking a margin on top of it.
        .padding(.horizontal, 59)
        .frame(height: 85)
        .background(Color.white.ignoresSafeArea(edges: .top))
        .ignoresSafeArea(edges: .horizontal)
    }

    // MARK: - Content

    private var settingsCard: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)

        return ZStack {
            shape
                .fill(Color.black)
                .frame(width: contentWidth, height: cardHeight)
                .offset(x: 4, y: 4)
                // Raw `.offset(x:)` mirrors under the app-wide RTL environment
                // (same caveat as HardShadowButtonStyle) — pin only this
                // decorative shadow layer back to LTR so it stays bottom-right.
                .environment(\.layoutDirection, .leftToRight)

            VStack(spacing: 0) {
                settingsRow(Strings.HomeSetting.soundEffects, isOn: $isSoundEffectsOn, height: 59, centerNudge: 2.75)
                rowDivider
                settingsRow(Strings.HomeSetting.music, isOn: $isMusicOn, height: 56, centerNudge: -1)
                rowDivider
                settingsRow(Strings.HomeSetting.vibration, isOn: $isVibrationOn, height: 57, centerNudge: -1.5)
            }
            .frame(width: contentWidth, height: cardHeight)
            .background(Color.white, in: shape)
            .overlay(shape.strokeBorder(Color.black, lineWidth: 4))
        }
        .modifier(ShadowCompensatedColumn(width: contentWidth))
    }

    private var rowDivider: some View {
        Color.black.frame(height: 3)
    }

    /// The spec's three rows are not equal: they are 59/56/57pt tall and the
    /// switch sits slightly off each row's center. `centerNudge` reproduces
    /// that offset (positive = down) by padding the opposite edge, which keeps
    /// the whole row tappable.
    private func settingsRow(_ title: String, isOn: Binding<Bool>, height: CGFloat, centerNudge: CGFloat) -> some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(SettingsRowToggleStyle())
            .padding(.top, max(centerNudge, 0) * 2)
            .padding(.bottom, max(-centerNudge, 0) * 2)
            .frame(height: height)
    }

    private var howToPlayButton: some View {
        NavigationLink(value: HomeDestination.howToPlay) {
            Text(Strings.HomeSetting.howToPlay)
        }
        .buttonStyle(
            HardShadowButtonStyle(
                fill: .brandYellow,
                borderColor: .black,
                borderWidth: 4,
                cornerRadius: 14,
                width: contentWidth,
                height: 48,
                shadowOffset: CGSize(width: 6, height: 4),
                shadowColor: .black,
                font: .titleScreen,
                textColor: .black
            )
        )
        .modifier(ShadowCompensatedColumn(width: contentWidth))
    }

    // MARK: - Footer

    private var footer: some View {
        Text(Strings.HomeSetting.caption)
            .font(.custom("Almarai-Regular", size: 11))
            // Literal black at 50% per spec, matching Home's own meta-caption
            // precedent (playerCountCaption).
            .foregroundStyle(Color.black.opacity(0.5))
            .multilineTextAlignment(.center)
            // Almarai's natural line box is taller than the 11pt the spec's
            // 100% line height implies; pin it so the gaps around it match.
            .frame(width: contentWidth, height: 11)
            // Centered over the card (x=187…657), not the screen.
            .modifier(ShadowCompensatedColumn(width: contentWidth))
    }
}

/// The spec places the card and button at x=187, i.e. the pair (with their
/// hard shadows) is centered on screen rather than the bare 470pt rectangles.
/// Reserving the extra 8pt and pinning to the physical left reproduces that
/// (trailing is the left edge under the app's forced RTL layout).
private struct ShadowCompensatedColumn: ViewModifier {
    let width: CGFloat

    func body(content: Content) -> some View {
        content.frame(width: width + 8, alignment: .trailing)
    }
}

#Preview {
    NavigationStack {
        HomeSettingView()
    }
    .environment(\.layoutDirection, .rightToLeft)
}
