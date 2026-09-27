import SwiftUI

/// One choice in the tag picker: the tag's art, name and what's left of it.
/// Once the tag is used up the card turns grey and stops responding.
struct BadgeOptionCard: View {
    let tag: ClueTag
    let caption: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ClueTagIcon(tag: tag, size: .option)
                    .opacity(isEnabled ? 1 : 0.4)
                    .frame(height: 36)
                    .padding(.top, 12)
                Text(tag.title)
                    .font(.labelSection)
                    .foregroundStyle(isEnabled ? Color.black : Color.lockedText)
                    .padding(.top, 8)
                Text(caption)
                    .font(.bodySmall)
                    .foregroundStyle(isEnabled ? Color.black.opacity(0.55) : Color.lockedText)
                    .padding(.top, 6)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .buttonStyle(
            HardShadowButtonStyle(
                fill: isEnabled ? .white : .lockedFill,
                borderColor: isEnabled ? .black : .lockedStroke,
                borderWidth: 3,
                cornerRadius: 16,
                width: 152,
                height: 98,
                shadowOffset: isEnabled ? CGSize(width: 4, height: 4) : .zero,
                shadowColor: .black,
                font: .labelSection,
                textColor: .black,
                cornerStyle: .circular
            )
        )
        .disabled(!isEnabled)
        .accessibilityLabel("\(tag.title)، \(caption)")
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 9) {
        BadgeOptionCard(tag: .mainIdea, caption: "استُخدمت", isEnabled: false, action: {})
        BadgeOptionCard(tag: .detail, caption: "7/10", isEnabled: true, action: {})
        BadgeOptionCard(tag: .secondaryIdea, caption: "اختيارية", isEnabled: true, action: {})
    }
    .padding(24)
    .background(Color.white)
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
