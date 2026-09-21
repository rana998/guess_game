import SwiftUI

/// The pushed-screen header shared by every screen after Home: an 85pt white
/// bar carrying the back button and screen title, closed by a 3pt black rule.
/// Both run edge to edge, past the safe area. `trailing` is an optional
/// accessory laid over the bar's reading-end corner (the physical left under
/// RTL), positioned by the caller — Enter Name puts its room-code pill there.
struct ScreenHeader<Trailing: View>: View {
    let title: String
    let backAccessibilityLabel: String
    /// Distance from the physical screen edge to the back button. Measured per
    /// mockup: Settings and Create Room sit at 59pt (where iPhone 16's landscape
    /// safe area ends), How to Play, Join Room and Enter Name at 41pt, so the
    /// header lets its content run past the safe area instead of stacking a
    /// margin on top of it.
    var horizontalInset: CGFloat = 59
    /// Gap between the back button and the title, also measured per mockup.
    var titleSpacing: CGFloat = 6
    let onBack: () -> Void
    let trailing: Trailing

    init(
        title: String,
        backAccessibilityLabel: String,
        horizontalInset: CGFloat = 59,
        titleSpacing: CGFloat = 6,
        onBack: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.backAccessibilityLabel = backAccessibilityLabel
        self.horizontalInset = horizontalInset
        self.titleSpacing = titleSpacing
        self.onBack = onBack
        self.trailing = trailing()
    }

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
            // An overlay, not another HStack child, so an empty accessory can't
            // add spacing or move the title.
            .overlay(alignment: .topTrailing) { trailing }
            .background(Color.white.ignoresSafeArea(edges: .top))
            .ignoresSafeArea(edges: .horizontal)

            Color.black
                .frame(height: 3)
                .ignoresSafeArea(edges: .horizontal)
        }
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(
        title: String,
        backAccessibilityLabel: String,
        horizontalInset: CGFloat = 59,
        titleSpacing: CGFloat = 6,
        onBack: @escaping () -> Void
    ) {
        self.init(
            title: title,
            backAccessibilityLabel: backAccessibilityLabel,
            horizontalInset: horizontalInset,
            titleSpacing: titleSpacing,
            onBack: onBack
        ) { EmptyView() }
    }
}

#Preview {
    ScreenHeader(title: Strings.HowPlay.title, backAccessibilityLabel: Strings.HowPlay.backAccessibilityLabel, horizontalInset: 41, titleSpacing: 10, onBack: {})
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.paper)
        .environment(\.layoutDirection, .rightToLeft)
}
