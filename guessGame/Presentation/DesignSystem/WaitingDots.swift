import SwiftUI

/// Three dots stepping from dark to light while the guessers wait for the
/// describer; still, in the mockup's shading, under Reduce Motion.
struct WaitingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let shades: [Double] = [1, 0.5, 0.25]
    private static let stepDuration: TimeInterval = 0.4

    var body: some View {
        TimelineView(.periodic(from: .now, by: Self.stepDuration)) { context in
            let animationStep = reduceMotion ? 0 : Int(context.date.timeIntervalSinceReferenceDate / Self.stepDuration) % Self.shades.count
            HStack(spacing: 7) {
                ForEach(Self.shades.indices, id: \.self) { position in
                    let shadeIndex = (position + Self.shades.count - animationStep) % Self.shades.count
                    Circle()
                        .fill(Color.black.opacity(Self.shades[shadeIndex]))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .accessibilityHidden(true)
    }
}
