import SwiftUI

/// The round's countdown: a yellow capsule with a clock ring and "m:ss".
struct RoundTimerPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .strokeBorder(Color.black, lineWidth: 3)
                .frame(width: 16, height: 16)
            Text(text)
                .font(.timerMono)
                .foregroundStyle(Color.black)
                .monospacedDigit()
        }
        .frame(width: 90, height: 40)
        .background(Color.brandYellow, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.black, lineWidth: 3))
        .hardShadow(in: Capsule(), offset: CGSize(width: 3, height: 3))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Strings.Round.timerLabel)
        .accessibilityValue(text)
        .accessibilityAddTraits(.updatesFrequently)
    }
}
