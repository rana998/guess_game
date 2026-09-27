import SwiftUI

/// Shown to everyone when a round ends: why it ended, the word, the points,
/// and the way on to the next round. No mockup exists for it yet, so it sticks
/// to the 8pt grid.
struct RoundEndedCard: View {
    struct Model: Hashable {
        let title: String
        let wordLine: String
        let pointsLine: String
        let buttonTitle: String
    }

    let model: Model
    let onContinue: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .circular)
        ZStack {
            // 48% black dims the board; tapping it does nothing.
            Color.black.opacity(0.48)
                .contentShape(Rectangle())
                .onTapGesture {}
                .accessibilityHidden(true)
            VStack(spacing: 8) {
                Text(model.title)
                    .font(.titleScreen)
                    .accessibilityIdentifier("game.roundEnded.title")
                Text(model.wordLine)
                    .font(.titleCard)
                    .accessibilityIdentifier("game.roundEnded.word")
                Text(model.pointsLine)
                    .font(.bodyStrong)
                    .foregroundStyle(Color.black.opacity(0.55))
                    .accessibilityIdentifier("game.roundEnded.points")
                Button(model.buttonTitle, action: onContinue)
                    .buttonStyle(.appGameAction(fill: .brandYellow, width: 224, height: 48))
                    .padding(.top, 8)
                    .accessibilityIdentifier("game.roundEnded.continue")
            }
            .foregroundStyle(Color.black)
            .multilineTextAlignment(.center)
            .padding(24)
            .frame(width: 424)
            .background(Color.white, in: shape)
            .overlay(shape.strokeBorder(Color.black, lineWidth: 4))
            .hardShadow(in: shape, offset: CGSize(width: 6, height: 6))
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isModal)
            .accessibilityIdentifier("game.roundEnded")
        }
    }
}
