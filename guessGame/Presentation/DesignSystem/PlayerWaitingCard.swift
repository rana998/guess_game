import SwiftUI

/// One player's 242×89 card in the waiting-room grid: avatar, name and caption,
/// their readiness pill and, for the owner looking at someone else's card, a
/// remove button. The viewer's own card is highlighted.
struct PlayerWaitingCard: View {
    /// What a card shows, decided once from the `Player` and who is looking,
    /// so the view stays declarative and the rules are testable.
    struct Model: Identifiable, Equatable {
        let id: String
        let name: String
        let color: Color
        let initial: String
        let caption: String?
        let isReady: Bool
        /// The viewer's own card.
        let isHighlighted: Bool
        /// Only the owner removes players, and never themselves.
        let showsRemoveButton: Bool
        let accessibilityLabel: String
        let removeAccessibilityLabel: String

        init(player: Player, currentPlayerId: String, viewerRole: RoomRole) {
            let isOwn = player.id == currentPlayerId
            let caption: String? = switch (isOwn, player.isOwner) {
            case (true, true): Strings.WaitingRoom.ownerSelfCaption
            case (true, false): Strings.WaitingRoom.selfCaption
            case (false, true): Strings.WaitingRoom.ownerCaption
            case (false, false): nil
            }
            let state = player.isReady ? Strings.WaitingRoom.ready : Strings.WaitingRoom.waiting

            id = player.id
            name = player.name
            color = player.color.color
            initial = AvatarBadge.initial(from: player.name, placeholder: "")
            self.caption = caption
            isReady = player.isReady
            isHighlighted = isOwn
            showsRemoveButton = viewerRole == .owner && !isOwn && !player.isOwner
            accessibilityLabel = [player.name, caption, state].compactMap { $0 }.joined(separator: "، ")
            removeAccessibilityLabel = Strings.WaitingRoom.removeAccessibilityLabel(name: player.name)
        }
    }

    let model: Model
    let isRemoveEnabled: Bool
    let onRemove: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .circular)

        // Reading order: the avatar is the physical right, the pill and remove
        // button the physical left.
        HStack(spacing: 0) {
            AvatarBadge(initial: model.initial, color: model.color, size: .medium)
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.titleCard)
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                if let caption = model.caption {
                    Text(caption)
                        .font(.bodySmall)
                        .foregroundStyle(Color.black.opacity(0.45))
                        .lineLimit(1)
                }
            }
            .padding(.leading, 6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(model.accessibilityLabel)
            Spacer(minLength: 4)
            ReadyStatusPill(status: model.isReady ? .ready : .waiting)
            if model.showsRemoveButton {
                RemovePlayerButton(accessibilityLabel: model.removeAccessibilityLabel, action: onRemove)
                    .padding(.leading, 3)
                    .disabled(!isRemoveEnabled)
                    .opacity(isRemoveEnabled ? 1 : 0.5)
            }
        }
        // Leading is the physical right (13pt to the avatar), trailing the
        // physical left, tighter when the remove button is there.
        .padding(.leading, 13)
        .padding(.trailing, model.showsRemoveButton ? 11 : 18)
        .frame(width: 242, height: 89)
        .background(model.isHighlighted ? Color.cardHighlight : Color.white, in: shape)
        .overlay(shape.strokeBorder(model.isHighlighted ? Color.brandYellow : Color.black, lineWidth: 4))
        .hardShadow(in: shape, offset: CGSize(width: 5, height: 5))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("waitingRoom.card.\(model.id)")
    }
}

#if DEBUG
#Preview {
    let room = Room.sampleLobby()
    VStack(spacing: 16) {
        ForEach(room.players.prefix(3)) { player in
            PlayerWaitingCard(
                model: .init(player: player, currentPlayerId: "lobby-0", viewerRole: .owner),
                isRemoveEnabled: true,
                onRemove: {}
            )
        }
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
