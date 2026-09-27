import SwiftUI

/// The black "X تختار الكلمة" pill at the top of the guessers' waiting screen:
/// the describer's avatar disc and what they're doing. Built to the
/// WaitingForWord mockup; it hugs its text, so its width follows the name.
struct DescriberStatusPill: View {
    let avatar: AvatarModel
    let text: String

    /// Measured on the mockup.
    private enum Metrics {
        static let height: CGFloat = 40
        static let avatarDiameter: CGFloat = 26
        static let avatarInset: CGFloat = 12
        static let avatarTextSpacing: CGFloat = 11
        static let textInset: CGFloat = 23
    }

    var body: some View {
        // Reading order: the avatar is the physical right.
        HStack(spacing: Metrics.avatarTextSpacing) {
            // A solid disc: unlike AvatarBadge, the mockup draws no ring around it.
            Text(avatar.initial)
                .font(.avatarInitialSmall)
                .foregroundStyle(Color.black)
                .frame(width: Metrics.avatarDiameter, height: Metrics.avatarDiameter)
                .background(avatar.color.color, in: Circle())
            Text(text)
                .font(.titleCard)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.leading, Metrics.avatarInset)
        .padding(.trailing, Metrics.textInset)
        .frame(height: Metrics.height)
        .background(Color.black, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

#if DEBUG
#Preview {
    DescriberStatusPill(
        avatar: AvatarModel(player: Player(id: "preview", name: "نهى", color: .green, isOwner: true)),
        text: Strings.WaitingForWord.describerChoosing(name: "نهى")
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
