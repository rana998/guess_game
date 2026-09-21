import SwiftUI

extension View {
    /// Draws the app's hard (never blurred) offset shadow as a flat shape behind
    /// the view, without changing its layout size. Same treatment as
    /// `HardShadowButtonStyle`, for surfaces that aren't buttons.
    func hardShadow<S: Shape>(in shape: S, offset: CGSize, color: Color = .black) -> some View {
        background {
            shape
                .fill(color)
                .offset(x: offset.width, y: offset.height)
                // Raw `.offset(x:)` mirrors under the app-wide RTL environment
                // (same caveat as HardShadowButtonStyle) — pin only this
                // decorative layer back to LTR so it stays bottom-right.
                .environment(\.layoutDirection, .leftToRight)
        }
    }
}
