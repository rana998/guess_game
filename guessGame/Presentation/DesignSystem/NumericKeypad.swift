import SwiftUI

/// The 3×4 numeric keypad: `1 2 3 / 4 5 6 / 7 8 9 / delete 0 confirm`, laid out
/// left to right like a phone keypad. It reports taps through callbacks and
/// holds no state of its own.
struct NumericKeypad: View {
    let deleteTitle: String
    let confirmTitle: String
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onConfirm: () -> Void
    var identifierPrefix = "joinRoom.key"

    private static let digitRows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Self.digitRows, id: \.self) { row in
                HStack(spacing: 9) {
                    ForEach(row, id: \.self) { digit in
                        digitKey(digit)
                    }
                }
            }
            HStack(spacing: 9) {
                key(.delete, title: deleteTitle, action: onDelete)
                digitKey(0)
                key(.confirm, title: confirmTitle, action: onConfirm)
            }
        }
        // Digits and phone keypads read left to right whatever the app's
        // layout direction, so 1 stays on the physical left.
        .environment(\.layoutDirection, .leftToRight)
    }

    private func digitKey(_ digit: Int) -> some View {
        key(.digit(digit), title: String(digit)) { onDigit(digit) }
    }

    private func key(_ kind: KeypadKey.Kind, title: String, action: @escaping () -> Void) -> some View {
        KeypadKey(kind: kind, title: title, action: action)
            .accessibilityIdentifier("\(identifierPrefix).\(kind.identifierSuffix)")
    }
}

#Preview {
    NumericKeypad(
        deleteTitle: Strings.JoinRoom.deleteKey,
        confirmTitle: Strings.JoinRoom.confirmKey,
        onDigit: { _ in },
        onDelete: {},
        onConfirm: {}
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
