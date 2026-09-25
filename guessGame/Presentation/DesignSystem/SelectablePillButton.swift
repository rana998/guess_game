import SwiftUI

/// A comic-style choice pill, white when unselected and brand green when
/// selected. Selection changes the fill only — the border, shadow and label
/// colors are identical in both states. `regular` is Create Room's big value
/// over a small caption; `compact` is the waiting room's 49×44 value-only pill.
struct SelectablePillButton: View {
    enum Size {
        case regular
        case compact
    }

    let value: String
    let caption: String?
    let isSelected: Bool
    let width: CGFloat
    let action: () -> Void
    var size: Size = .regular

    init(
        value: String,
        caption: String?,
        isSelected: Bool,
        width: CGFloat,
        size: Size = .regular,
        action: @escaping () -> Void
    ) {
        self.value = value
        self.caption = caption
        self.isSelected = isSelected
        self.width = width
        self.size = size
        self.action = action
    }

    var body: some View {
        Group {
            switch size {
            case .regular: regular
            case .compact: compact
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var regular: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(value)
                    .font(.pillValue)
                    .foregroundStyle(Color.black)
                    .frame(height: 27)
                if let caption {
                    Text(caption)
                        .font(.bodyMetaSmall)
                        .foregroundStyle(Color.black.opacity(0.55))
                        .frame(height: 12)
                        .padding(.top, -3)
                }
            }
            .padding(.top, 14)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .buttonStyle(
            HardShadowButtonStyle(
                fill: isSelected ? .brandLime : .white,
                borderColor: .black,
                borderWidth: 4,
                cornerRadius: 14,
                width: width,
                height: 64,
                shadowOffset: CGSize(width: 5, height: 5),
                shadowColor: .black,
                font: .pillValue,
                textColor: .black,
                cornerStyle: .circular
            )
        )
    }

    private var compact: some View {
        Button(action: action) {
            Text(value)
        }
        .buttonStyle(
            HardShadowButtonStyle(
                fill: isSelected ? .brandLime : .white,
                borderColor: .black,
                borderWidth: 3,
                cornerRadius: 11,
                width: width,
                height: 44,
                shadowOffset: CGSize(width: 3, height: 3),
                shadowColor: .black,
                font: .pillMono,
                textColor: .black,
                cornerStyle: .circular
            )
        )
    }
}

#Preview {
    HStack(spacing: 13) {
        SelectablePillButton(value: "3", caption: Strings.CreateRoom.playersCaption, isSelected: false, width: 76, action: {})
        SelectablePillButton(value: "6", caption: Strings.CreateRoom.playersCaption, isSelected: true, width: 76, action: {})
        SelectablePillButton(value: "60", caption: nil, isSelected: true, width: 49, size: .compact, action: {})
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
