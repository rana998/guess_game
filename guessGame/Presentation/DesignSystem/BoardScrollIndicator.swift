import SwiftUI

/// The describer board's always-visible scroll bar: a black thumb on a grey
/// 4pt track, sized and moved by how much of the grid is in view.
struct BoardScrollIndicator: View {
    /// The visible share of the scrolled content, 0…1.
    let visibleFraction: CGFloat
    /// How far the content is scrolled, 0 (top) … 1 (bottom).
    let scrollProgress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let trackHeight = geometry.size.height
            let thumbHeight = trackHeight * min(1, max(0, visibleFraction))
            let thumbTop = (trackHeight - thumbHeight) * min(1, max(0, scrollProgress))
            ZStack(alignment: .top) {
                // 35% black on Paper is the mockup's track grey.
                Rectangle()
                    .fill(Color.black.opacity(0.35))
                Rectangle()
                    .fill(Color.black)
                    .frame(height: thumbHeight)
                    .offset(y: thumbTop)
            }
        }
        .frame(width: 4)
        .accessibilityHidden(true)
    }
}
