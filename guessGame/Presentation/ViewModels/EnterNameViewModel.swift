import Foundation
import Observation

/// What Enter Name edits and shows: the name and color being chosen, and the
/// room being joined (its code and the players already in it). Holds no UI
/// types, so the rules are testable without a view.
@Observable
final class EnterNameViewModel {
    let room: Room
    var name: String
    var color: PlayerColor

    /// Called with the trimmed name and chosen color when the player enters the
    /// room. No lobby exists yet, so the default does nothing.
    @ObservationIgnored private let onSubmit: (String, PlayerColor) -> Void

    init(
        room: Room,
        name: String = "",
        color: PlayerColor = .green,
        onSubmit: @escaping (String, PlayerColor) -> Void = { _, _ in }
    ) {
        self.room = room
        self.name = name
        self.color = color
        self.onSubmit = onSubmit
    }

    var roomCode: String { room.code }

    /// The footer's "N من M لاعبين", computed from the room.
    var playersCountText: String {
        Strings.EnterName.playersCount(count: room.players.count, capacity: room.capacity)
    }

    var rows: [PlayerRow.Model] {
        room.players.map { PlayerRow.Model(player: $0, ownerCaption: Strings.EnterName.ownerCaption) }
    }

    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canSubmit: Bool { !trimmedName.isEmpty }

    func submit() {
        guard canSubmit else { return }
        onSubmit(trimmedName, color)
    }
}
