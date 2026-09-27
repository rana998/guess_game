import SwiftUI

/// A capsule carrying a player's small avatar and a line of text about them:
/// the black "who's choosing the word" pill and the green "describing now" one.
struct AvatarLabelCapsule: View {
    let avatar: AvatarModel
    let text: String
    let fill: Color
    let textColor: Color
    let font: Font
    let borderWidth: CGFloat
    var height: CGFloat = 40
    /// The avatar's distance from the capsule's reading-start end, and from the text.
    var avatarInset: CGFloat = 12
    var avatarSpacing: CGFloat = 11

    var body: some View {
        // The mockup whitens a green avatar on the green pill so it stays visible.
        let badgeColor = avatar.color == .green && fill == .brandLime ? Color.white : avatar.color.color
        HStack(spacing: avatarSpacing) {
            AvatarBadge(initial: avatar.initial, color: badgeColor, size: .mini)
            Text(text)
                .font(font)
                .foregroundStyle(textColor)
                .lineLimit(1)
        }
        .padding(.leading, avatarInset)
        .padding(.trailing, 16)
        .frame(height: height)
        .background(fill, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.black, lineWidth: borderWidth))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}
