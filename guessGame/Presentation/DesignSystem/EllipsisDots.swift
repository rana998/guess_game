import SwiftUI

/// Three black dots, the "more" glyph on Home's settings badge and the waiting
/// room's kebab. Drawn as circles: the mockups' dots (5pt, 11pt pitch) are much
/// larger than SF Symbols' "ellipsis" glyph at any nearby size.
struct EllipsisDots: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in
                Circle().fill(Color.black).frame(width: 5, height: 5)
            }
        }
    }
}

#if DEBUG
#Preview {
    EllipsisDots()
        .padding(24)
        .background(Color.white)
}
#endif
