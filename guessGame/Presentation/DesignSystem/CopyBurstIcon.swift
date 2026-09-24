import SwiftUI

/// The copy chip's little comic burst: a 12-point yellow star with a thin ink
/// outline and a green oval in the middle, 22×18. Drawn as a vector so it has
/// no asset to keep in sync. Decorative: the chip's label says "copy".
struct CopyBurstIcon: View {
    var body: some View {
        ZStack {
            Burst()
                .fill(Color.brandYellow)
            Burst()
                .stroke(Color.inkStroke, style: StrokeStyle(lineWidth: 0.75, lineJoin: .miter))
            Ellipse()
                .fill(Color.brandLime)
                .frame(width: 10, height: 11)
                .offset(y: 0.5)
        }
        .frame(width: 22, height: 18)
        .accessibilityHidden(true)
    }

    /// A star whose outer points lie on the ellipse inscribed in the frame (inset
    /// for the outline), with one spike straight up and one straight down.
    struct Burst: Shape {
        let points = 12
        let innerRatio: CGFloat = 0.70

        func path(in rect: CGRect) -> Path {
            let box = rect.insetBy(dx: 0.5, dy: 0.5)
            let center = CGPoint(x: box.midX, y: box.midY)
            let step = CGFloat.pi * 2 / CGFloat(points)
            var path = Path()
            for index in 0..<(points * 2) {
                let isOuter = index.isMultiple(of: 2)
                let scale = isOuter ? 1 : innerRatio
                let angle = -CGFloat.pi / 2 + CGFloat(index) * step / 2
                let point = CGPoint(
                    x: center.x + box.width / 2 * scale * cos(angle),
                    y: center.y + box.height / 2 * scale * sin(angle)
                )
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            return path
        }
    }
}

#if DEBUG
#Preview {
    CopyBurstIcon()
        .scaleEffect(4)
        .padding(60)
        .background(Color.white)
}
#endif
