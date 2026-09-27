import SwiftUI

/// The copy chip's little comic burst: a 12-point yellow star with a thin ink
/// outline and a green oval in the middle, 22×18. Drawn as a vector so it has
/// no asset to keep in sync. Decorative: the chip's label says "copy".
struct CopyBurstIcon: View {
    var body: some View {
        ZStack {
            BurstShape()
                .fill(Color.brandYellow)
            BurstShape()
                .stroke(Color.inkStroke, style: StrokeStyle(lineWidth: 0.75, lineJoin: .miter))
            Ellipse()
                .fill(Color.brandLime)
                .frame(width: 10, height: 11)
                .offset(y: 0.5)
        }
        .frame(width: 22, height: 18)
        .accessibilityHidden(true)
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
