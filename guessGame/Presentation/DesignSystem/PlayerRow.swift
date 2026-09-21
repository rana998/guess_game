import SwiftUI

/// One player in a room list: a small avatar, the name, and — for the owner —
/// a gray caption at the far end. Fixed 38.25pt tall; the list puts a dashed
/// rule after each row.
struct PlayerRow: View {
    /// What a row shows, decided once from the `Player` so the view stays
    /// declarative and the rules are testable.
    struct Model: Identifiable, Equatable {
        let id: String
        let name: String
        let color: Color
        let initial: String
        /// Only the owner has one.
        let caption: String?
        let accessibilityLabel: String

        init(player: Player, ownerCaption: String) {
            id = player.id
            name = player.name
            color = player.color.color
            initial = AvatarBadge.initial(from: player.name, placeholder: "")
            caption = player.isOwner ? ownerCaption : nil
            accessibilityLabel = player.isOwner ? "\(player.name)، \(ownerCaption)" : player.name
        }
    }

    static let height: CGFloat = 38.25

    let model: Model

    var body: some View {
        // The avatar is first, so it sits at the reading start (physical right).
        HStack(spacing: 8) {
            AvatarBadge(initial: model.initial, color: model.color, size: .small)
            Text(model.name)
                .font(.labelSection)
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
            if let caption = model.caption {
                Text(caption)
                    .font(.bodySmall)
                    .foregroundStyle(Color.black.opacity(0.45))
                    .fixedSize()
                    // The caption sits 7pt further in than the avatar's own
                    // 16pt margin, per the mockup.
                    .padding(.trailing, 7)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: Self.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityLabel)
    }
}

#Preview {
    VStack(spacing: 0) {
        PlayerRow(model: .init(player: Player(id: "1", name: "نهى", color: .green, isOwner: true), ownerCaption: Strings.EnterName.ownerCaption))
        PlayerRow(model: .init(player: Player(id: "2", name: "سلمان", color: .teal, isOwner: false), ownerCaption: Strings.EnterName.ownerCaption))
    }
    .frame(width: 262)
    .background(Color.white)
    .padding(24)
    .environment(\.layoutDirection, .rightToLeft)
}
