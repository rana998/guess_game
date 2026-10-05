import SwiftUI

/// A comic burst: a star whose outer points lie on the ellipse inscribed in the
/// frame (inset for the outline), with one spike straight up. The copy chip's
/// icon and the word card's backdrop.
struct BurstShape: Shape {
    var pointCount = 12
    var innerRadiusRatio: CGFloat = 0.70
    var inset: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: inset, dy: inset)
        let center = CGPoint(x: insetRect.midX, y: insetRect.midY)
        let anglePerPoint = CGFloat.pi * 2 / CGFloat(pointCount)
        var path = Path()
        for vertexIndex in 0..<(pointCount * 2) {
            let isOuterVertex = vertexIndex.isMultiple(of: 2)
            let radiusScale = isOuterVertex ? 1 : innerRadiusRatio
            let angle = -CGFloat.pi / 2 + CGFloat(vertexIndex) * anglePerPoint / 2
            let vertex = CGPoint(
                x: center.x + insetRect.width / 2 * radiusScale * cos(angle),
                y: center.y + insetRect.height / 2 * radiusScale * sin(angle)
            )
            if vertexIndex == 0 {
                path.move(to: vertex)
            } else {
                path.addLine(to: vertex)
            }
        }
        path.closeSubpath()
        return path
    }
}
