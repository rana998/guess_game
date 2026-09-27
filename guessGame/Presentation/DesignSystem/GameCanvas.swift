import SwiftUI

/// Hosts a round screen's 852×393 layout: Paper everywhere, the white top band
/// running edge to edge behind the layout's own header, and the layout scaled
/// down (never up) to fit narrower screens. `contentAlignment` lets the guess
/// screen keep its bottom edge in view above the keyboard. The layout is placed
/// with `canvasCenter(x:y:)` in the mockup's physical coordinates.
struct GameCanvas<Content: View>: View {
    var topBarHeight: CGFloat?
    var referenceWidth: CGFloat = GameLayout.canvasSize.width
    var contentAlignment: VerticalAlignment = .top
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { geometry in
            let scale = GameLayout.fitScale(forWidth: geometry.size.width, referenceWidth: referenceWidth)
            let anchor: UnitPoint = contentAlignment == .bottom ? .bottom : .top
            ZStack(alignment: .top) {
                Color.paper
                if let topBarHeight {
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: topBarHeight * scale)
                        Color.black
                            .frame(height: 3 * scale)
                    }
                }
                content
                    .frame(width: GameLayout.canvasSize.width, height: GameLayout.canvasSize.height)
                    // Left to right so canvas points aren't mirrored; each placed
                    // view switches back to RTL (see canvasCenter).
                    .environment(\.layoutDirection, .leftToRight)
                    .scaleEffect(scale, anchor: anchor)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: Alignment(horizontal: .center, vertical: contentAlignment)
                    )
            }
        }
    }
}
