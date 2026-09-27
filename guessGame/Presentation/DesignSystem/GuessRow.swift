import SwiftUI

/// One guess in the guess panel: who guessed and what, with the correct one
/// in green and checked.
struct GuessRow: View {
    struct Model: Identifiable, Hashable {
        let id: Int
        let playerName: String
        let text: String
        let isCorrect: Bool
        let accessibilityLabel: String
    }

    let model: Model

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .circular)
        // Reading order: the name is the physical right, the check the left.
        HStack(spacing: 6) {
            Text(model.playerName)
                .font(.bodySmall)
                .foregroundStyle(Color.black.opacity(0.5))
                .lineLimit(1)
            Text(model.text)
                .font(.labelSection)
                .foregroundStyle(Color.black)
                .lineLimit(1)
            Spacer(minLength: 0)
            if model.isCorrect {
                checkBadge
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 8)
        // The mockup's correct row is taller, to fit its check badge.
        .frame(width: 252, height: model.isCorrect ? 39 : 31)
        .background(model.isCorrect ? Color.tintLime : Color.paper, in: shape)
        // 18% black is the mockup's hairline around an ordinary guess.
        .overlay(shape.strokeBorder(model.isCorrect ? Color.brandLime : Color.black.opacity(0.18), lineWidth: 2))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityLabel)
    }

    private var checkBadge: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(Color.black)
            .frame(width: 22, height: 22)
            .background(Color.brandLime, in: Circle())
            .overlay(Circle().strokeBorder(Color.black, lineWidth: 2))
    }
}
