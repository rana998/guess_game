import SwiftUI

/// The room code's boxes in entry order, first digit at the physical left.
/// Digits are typed left to right like any number, so the row is pinned to LTR
/// instead of following the app's RTL layout.
struct CodeDigitRow: View {
    struct Slot: Equatable {
        let digit: Character?
        let style: CodeDigitBox.Style
    }

    let slots: [Slot]
    /// VoiceOver name of the box at a zero-based index, e.g. "box 1 of 4".
    let boxLabel: (Int) -> String
    /// VoiceOver value of a box that holds no digit.
    let emptyValue: String
    let identifierPrefix: String

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                CodeDigitBox(digit: slot.digit, style: slot.style)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(boxLabel(index))
                    .accessibilityValue(slot.digit.map { String($0) } ?? emptyValue)
                    .accessibilityAddTraits(slot.style == .active ? .isSelected : [])
                    .accessibilityIdentifier("\(identifierPrefix).\(index)")
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    CodeDigitRow(
        slots: [
            .init(digit: "8", style: .filled),
            .init(digit: "7", style: .filled),
            .init(digit: nil, style: .active),
            .init(digit: nil, style: .empty),
        ],
        boxLabel: { Strings.JoinRoom.boxLabel(position: $0 + 1, of: 4) },
        emptyValue: Strings.JoinRoom.boxEmptyValue,
        identifierPrefix: "preview.box"
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
