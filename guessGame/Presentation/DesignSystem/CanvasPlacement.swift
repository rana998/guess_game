import SwiftUI

extension View {
    /// Centers the view on a point of the round screens' 852×393 canvas, in the
    /// mockup's physical coordinates (x from the left edge). The view itself
    /// keeps the app's right-to-left layout.
    func canvasCenter(x: CGFloat, y: CGFloat) -> some View {
        environment(\.layoutDirection, .rightToLeft)
            .position(x: x, y: y)
    }
}
