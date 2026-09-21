import SwiftUI

/// One key of `NumericKeypad`: a digit, the red delete key or the green confirm
/// key. All three are `HardShadowButtonStyle` keys that differ only in fill and
/// label color.
struct KeypadKey: View {
    enum Kind: Equatable {
        case digit(Int)
        case delete
        case confirm

        /// Last path component of the key's accessibility identifier.
        var identifierSuffix: String {
            switch self {
            case .digit(let value): String(value)
            case .delete: "delete"
            case .confirm: "confirm"
            }
        }
    }

    let kind: Kind
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.appKey(fill: fill, textColor: textColor))
    }

    private var fill: Color {
        switch kind {
        case .digit: .white
        case .delete: .brandRed
        case .confirm: .brandLime
        }
    }

    private var textColor: Color {
        kind == .delete ? .white : .black
    }
}

#Preview {
    HStack(spacing: 9) {
        KeypadKey(kind: .delete, title: Strings.JoinRoom.deleteKey, action: {})
        KeypadKey(kind: .digit(0), title: "0", action: {})
        KeypadKey(kind: .confirm, title: Strings.JoinRoom.confirmKey, action: {})
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
