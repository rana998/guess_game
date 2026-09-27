import SwiftUI

/// A comic burst: a star whose outer points lie on the ellipse inscribed in the
/// frame (inset for the outline), with one spike straight up. The copy chip's
/// icon and the word card's backdrop.
struct BurstShape: Shape {
    var points = 12
    var innerRatio: CGFloat = 0.70
    var inset: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        let box = rect.insetBy(dx: inset, dy: inset)
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
