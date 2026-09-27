import SwiftUI

/// A dashed place in the guessers' main-idea box, waiting for the describer's
/// next image. Decorative: the box's caption says it's waiting.
struct EmptyClueSlot: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .circular)
            .fill(Color.white.opacity(0.5))
            // Padding stands in for strokeBorder: DashedRoundedRect isn't an
            // InsettableShape, and the 3pt line must stay inside the frame.
            .overlay(
                DashedRoundedRect(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 3, dash: [8, 6]))
                    .padding(1.5)
            )
            .frame(width: 84, height: 84)
            .accessibilityHidden(true)
    }
}
