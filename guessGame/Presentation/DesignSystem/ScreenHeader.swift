import SwiftUI

/// The pushed-screen header shared by HomeSettingView and HowPlayView: an 85pt
/// white bar carrying the back button and screen title, closed by a 3pt black
/// rule. Both run edge to edge, past the safe area.
struct ScreenHeader: View {
    let title: String
    let backAccessibilityLabel: String
    /// Distance from the physical screen edge to the back button. Measured per
    /// mockup: Settings sits at 59pt (where iPhone 16's landscape safe area
    /// ends), How to Play at 41pt, so the header lets its content run past the
    /// safe area instead of stacking a margin on top of it.
    var horizontalInset: CGFloat = 59
    /// Gap between the back button and the title, also measured per mockup.
    var titleSpacing: CGFloat = 6
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // First child sits on the right under the app's forced RTL layout.
            HStack(spacing: titleSpacing) {
                RoundedChevronButton(action: onBack)
                    .accessibilityLabel(backAccessibilityLabel)
                Text(title)
                    .font(.titleScreen)
                    .foregroundStyle(Color.black)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, horizontalInset)
            .frame(height: 85)
            .background(Color.white.ignoresSafeArea(edges: .top))
            .ignoresSafeArea(edges: .horizontal)

            Color.black
                .frame(height: 3)
                .ignoresSafeArea(edges: .horizontal)
        }
    }
}

#Preview {
    ScreenHeader(title: Strings.HowPlay.title, backAccessibilityLabel: Strings.HowPlay.backAccessibilityLabel, horizontalInset: 41, titleSpacing: 10, onBack: {})
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.paper)
        .environment(\.layoutDirection, .rightToLeft)
}
