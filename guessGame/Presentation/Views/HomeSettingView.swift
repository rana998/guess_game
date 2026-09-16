import SwiftUI

/// Settings screen pushed from Home's "..." button. Three UI-only toggle rows
/// (sound effects, music, vibration) plus a "How to Play" entry point.
///
/// Every visual element here — back button, card, toggles, CTA — is a
/// dedicated, independent build for this screen. By explicit product
/// decision none of it reuses or alters Home's own button styles, even
/// where a component looks similar (e.g. "كيف تلعب؟" exists on both screens
/// but as two separate styles); visual unification between the two screens
/// is a separate future task.
struct HomeSettingView: View {
    @Environment(\.dismiss) private var dismiss

    // UI-only state for now — no persistence/backend wiring yet, matching
    // CLAUDE.md's "Non-Goals" phasing for this project.
    @State private var isSoundEffectsOn = true
    @State private var isMusicOn = false
    @State private var isVibrationOn = true

    /// Matches "إنشاء غرفة" CTA's width (AppButtonStyle.appPrimary) so the
    /// card and the How to Play button line up with the rest of the app's CTAs.
    private let contentWidth: CGFloat = 288
    private let rowHeight: CGFloat = 62

    /// Dedicated to this screen only: reuses the generic HardShadowButtonStyle
    /// rendering engine with its own configuration, not Home's `.appPrimary`
    /// or `.appTertiaryDashed` presets. Height matches DESIGN_SYSTEM.md's
    /// "Prominent CTA height: 50pt" (measured against the mockup directly,
    /// not Home's own 60pt CTAs — Home's frame happens to be a different size).
    private var howToPlayButtonStyle: HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: .brandYellow,
            borderColor: .inkStroke,
            borderWidth: 4,
            cornerRadius: 14,
            width: contentWidth,
            height: 50,
            shadowOffset: CGSize(width: 6, height: 4),
            shadowColor: .black,
            font: .displayCTA,
            textColor: .inkStroke
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Rectangle()
                .fill(Color.black)
                .frame(height: 3)
            content
        }
        .background(Color.paper)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .top)

            HStack(spacing: 12) {
                RoundedChevronButton(action: { dismiss() })
                    .accessibilityLabel(Strings.HomeSetting.backAccessibilityLabel)
                Text(Strings.HomeSetting.title)
                    .font(.titleScreen)
                    .foregroundStyle(Color.inkText)
            }
            // leading = right edge under the app's forced RTL environment,
            // matching the back-button-top-right convention.
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }
        .frame(height: 85)
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 0) {
            settingsCard
                .padding(.top, 16)
            howToPlayButton
                .padding(.top, 16)
            captionText
                .padding(.top, 12)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var settingsCard: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)
        let cardHeight = rowHeight * 3

        return ZStack {
            shape
                .fill(Color.black)
                .frame(width: contentWidth, height: cardHeight)
                .offset(x: 4, y: 4)
                // Raw `.offset(x:)` mirrors under the app-wide RTL environment
                // (same caveat as HardShadowButtonStyle) — pin only this
                // decorative shadow layer back to LTR so it stays bottom-right
                // as specified. The row content below stays under real RTL so
                // the Arabic text/toggle ordering still mirrors correctly.
                .environment(\.layoutDirection, .leftToRight)

            VStack(spacing: 0) {
                settingsRow(title: Strings.HomeSetting.soundEffects, isOn: $isSoundEffectsOn)
                rowDivider
                settingsRow(title: Strings.HomeSetting.music, isOn: $isMusicOn)
                rowDivider
                settingsRow(title: Strings.HomeSetting.vibration, isOn: $isVibrationOn)
            }
            .frame(width: contentWidth, height: cardHeight)
            .background(Color.white, in: shape)
            .overlay(shape.strokeBorder(Color.inkStroke, lineWidth: 4))
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.black)
            .frame(height: 3)
    }

    private func settingsRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.titleCard)
                .foregroundStyle(Color.inkText)
            Spacer()
            Toggle(isOn: isOn) { EmptyView() }
                .toggleStyle(.switch)
                .tint(Color.brandLime)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .frame(height: rowHeight)
        .accessibilityElement(children: .combine)
    }

    private var howToPlayButton: some View {
        NavigationLink(value: HomeDestination.howToPlay) {
            Text(Strings.HomeSetting.howToPlay)
        }
        .buttonStyle(howToPlayButtonStyle)
    }

    private var captionText: some View {
        Text(Strings.HomeSetting.caption)
            .font(.custom("Almarai-Regular", size: 11))
            // Literal black, not the InkText token, matching Home's own
            // meta-caption precedent (playerCountCaption) — this footnote
            // stays literally black per spec in both appearances.
            .foregroundStyle(Color.black.opacity(0.5))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        HomeSettingView()
    }
}
