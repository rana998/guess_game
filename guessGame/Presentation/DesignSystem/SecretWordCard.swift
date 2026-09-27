import SwiftUI

/// The describer's word reveal: "كلمتك السرية", the word, and its difficulty chip.
struct SecretWordCard: View {
    let word: String
    let chipText: String

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .circular)
        VStack(spacing: 0) {
            Text(Strings.WordCard.secretCaption)
                .font(.captionStrong)
                .foregroundStyle(Color.black.opacity(0.5))
                .padding(.top, 20)
            Text(word)
                .font(.wordDisplay)
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 16)
                .padding(.top, 5)
                .accessibilityIdentifier("game.secretWord")
            Text(chipText)
                .font(.messageBanner)
                .foregroundStyle(Color.black)
                .padding(.horizontal, 10)
                .frame(height: 26)
                .background(Color.brandYellow, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.black, lineWidth: 3))
                .padding(.top, 8)
                .accessibilityIdentifier("game.difficultyChip")
            Spacer(minLength: 0)
        }
        .frame(width: 231, height: 126)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 4))
        .hardShadow(in: shape, offset: CGSize(width: 8, height: 8))
        .accessibilityElement(children: .contain)
    }
}
