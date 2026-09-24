/// One place in the waiting-room grid: a player's card, or an empty seat up to the room's capacity.
enum WaitingRoomSlot: Identifiable, Equatable {
    case player(PlayerWaitingCard.Model)
    case empty(index: Int)

    var id: String {
        switch self {
        case .player(let model): model.id
        case .empty(let index): "empty-\(index)"
        }
    }
}
