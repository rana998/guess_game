import SwiftUI

/// A comic-style choice pill: a big value over a small caption, white when
/// unselected and brand green when selected. Selection changes the fill only —
/// the border, shadow and label colors are identical in both states.
struct SelectablePillButton: View {
    let value: String
    let caption: String
    let isSelected: Bool
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(value)
                    .font(.pillValue)
                    .foregroundStyle(Color.black)
                    .frame(height: 27)
                Text(caption)
                    .font(.bodyMetaSmall)
                    .foregroundStyle(Color.black.opacity(0.55))
                    .frame(height: 12)
                    .padding(.top, -3)
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
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack(spacing: 13) {
        SelectablePillButton(value: "3", caption: Strings.CreateRoom.playersCaption, isSelected: false, width: 76, action: {})
        SelectablePillButton(value: "6", caption: Strings.CreateRoom.playersCaption, isSelected: true, width: 76, action: {})
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
