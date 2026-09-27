import SwiftUI

/// A right-pointing chevron, drawn as a path rather than an SF Symbol so its
/// size is exact. A Shape's coordinates are absolute, so it points right in
/// both layout directions instead of mirroring under the app's forced RTL.
struct ChevronShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
