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

            Spacer(minLength: 0)
            VStack(spacing: 16) {
                settingsCard
                howToPlayButton
            }
            // Capped, not fixed, so the column still fits narrower iPhones.
            .frame(maxWidth: contentWidth)
            .padding(.horizontal, 16)
            Spacer(minLength: 0)

            footer
        }
        .frame(maxWidth: .infinity)
        .background(Color.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        // First child sits on the right under the app's forced RTL layout.
        HStack(spacing: 12) {
            CircleBackButton(action: { dismiss() })
                .accessibilityLabel(Strings.HomeSetting.backAccessibilityLabel)
            Text(Strings.HomeSetting.title)
                .font(.titleScreen)
                .foregroundStyle(Color.black)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 85)
        // The white band runs edge to edge, behind the notch/rounded corners.
        .background(Color.white.ignoresSafeArea(edges: [.top, .horizontal]))
    }

    // MARK: - Content

    private var settingsCard: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)

        return VStack(spacing: 0) {
            settingsRow(Strings.HomeSetting.soundEffects, isOn: $isSoundEffectsOn)
            settingsRow(Strings.HomeSetting.music, isOn: $isMusicOn)
            settingsRow(Strings.HomeSetting.vibration, isOn: $isVibrationOn)
        }
        .frame(height: cardHeight)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 4))
    }

    private func settingsRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(SettingsRowToggleStyle())
    }

    private var howToPlayButton: some View {
        NavigationLink(value: HomeDestination.howToPlay) {
            Text(Strings.HomeSetting.howToPlay)
        }
        .buttonStyle(
            FlatOutlineButtonStyle(
                fill: .brandYellow,
                borderColor: .black,
                borderWidth: 4,
                cornerRadius: 14,
                height: 48,
                font: .titleScreen,
                textColor: .black
            )
        )
    }

    // MARK: - Footer

    private var footer: some View {
        Text(Strings.HomeSetting.caption)
            .font(.custom("Almarai-Regular", size: 11))
            // Literal black at 50% per spec, matching Home's own meta-caption
            // precedent (playerCountCaption).
            .foregroundStyle(Color.black.opacity(0.5))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
}

#Preview {
    NavigationStack {
        HomeSettingView()
    }
    .environment(\.layoutDirection, .rightToLeft)
}
