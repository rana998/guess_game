import SwiftUI

/// A 44×44pt yellow rounded-square icon button carrying a right-pointing
/// chevron, used for back navigation per the app's RTL convention (button
/// sits top-right, chevron points right toward the edge).
///
/// This is a brand-new component dedicated to HomeSettingView: it reuses the
/// generic `HardShadowButtonStyle` rendering engine (hard offset shadow,
/// inside stroke, press-shift) with its own yellow/3pt configuration, rather
/// than any of Home's existing button presets — Home is intentionally left
/// untouched by this screen's work.
struct RoundedChevronButton: View {
    var action: () -> Void

    private static let style = HardShadowButtonStyle(
        fill: .brandYellow,
        borderColor: .inkStroke,
        borderWidth: 3,
        cornerRadius: 14,
        width: 44,
        height: 44,
        shadowOffset: CGSize(width: 3, height: 3),
        shadowColor: .black,
        font: .system(size: 18, weight: .bold),
        textColor: .inkStroke
    )

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
        }
        .buttonStyle(Self.style)
    }
}

#Preview {
    RoundedChevronButton(action: {})
        .padding(40)
        .background(Color.paper)
}
