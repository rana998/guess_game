import SwiftUI

/// A 44×44pt yellow rounded-square back button carrying a right-pointing
/// chevron, per the app's RTL convention (button sits top-right, chevron
/// points toward that edge). Reuses `HardShadowButtonStyle` for the hard
/// shadow, inside stroke and press-shift.
struct RoundedChevronButton: View {
    var action: () -> Void

    private static let style = HardShadowButtonStyle(
        fill: .brandYellow,
        borderColor: .black,
        borderWidth: 3,
        cornerRadius: 14,
        width: 44,
        height: 44,
        shadowOffset: CGSize(width: 3, height: 3),
        shadowColor: .black,
        font: .body,
        textColor: .black
    )

    var body: some View {
        Button(action: action) {
            Chevron()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 7, height: 14)
        }
        .buttonStyle(Self.style)
    }
}

/// Drawn as a path rather than an SF Symbol so its size is exactly 7×14pt.
/// A Shape's coordinates are absolute, so it points right in both layout
/// directions instead of mirroring under the app's forced RTL.
private struct Chevron: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

#Preview {
    RoundedChevronButton(action: {})
        .padding(40)
        .background(Color.white)
}
