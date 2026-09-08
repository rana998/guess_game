import SwiftUI

/// Stroked/outlined comic-style text. SwiftUI has no native text-stroke API, so this
/// stacks copies of the text offset in a ring behind the fill color — the standard
/// SwiftUI workaround for an outlined wordmark. Cheap: renders once per appearance
/// on a static hero element, not in a list or animation loop.
struct ComicOutlineText: View {
    let text: String
    var font: Font
    var fillColor: Color
    var strokeColor: Color
    var strokeWidth: CGFloat

    var body: some View {
        ZStack {
            ForEach(Array(strokeOffsets.enumerated()), id: \.offset) { _, point in
                Text(text)
                    .font(font)
                    .foregroundStyle(strokeColor)
                    .offset(x: point.x, y: point.y)
            }
            Text(text)
                .font(font)
                .foregroundStyle(fillColor)
        }
    }

    private var strokeOffsets: [CGPoint] {
        stride(from: 0.0, to: 360.0, by: 45.0).map { degrees in
            let radians = degrees * .pi / 180
            return CGPoint(x: cos(radians) * strokeWidth, y: sin(radians) * strokeWidth)
        }
    }
}
