import SwiftUI

/// A 44pt yellow circular back button with a right-pointing chevron, per the
/// app's RTL convention (button sits top-right, chevron points toward that
/// edge). Flat by design — a 3pt ink outline, no hard shadow.
struct CircleBackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Chevron()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 7, height: 14)
                .frame(width: 44, height: 44)
                .background(Color.brandYellow, in: Circle())
                // strokeBorder keeps the 3pt line inside the 44pt diameter.
                .overlay(Circle().strokeBorder(Color.black, lineWidth: 3))
                .contentShape(Circle())
        }
        .buttonStyle(PressFadeButtonStyle())
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

private struct PressFadeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

#Preview {
    CircleBackButton(action: {})
        .padding(40)
        .background(Color.white)
}
