import Foundation
import Observation

/// What Create Room edits (name, avatar color, player count, round length) and
/// the room it builds from them. Rooms are local until the create-room use case
/// exists: the code comes from `LocalRoomCode` and the owner is the only player.
@Observable
final class CreateRoomViewModel {
    var name = ""
    var avatarColor: PlayerColor = .green
    var playerCount = Room.maximumPlayers
    var roundSeconds = Room.defaultRoundSeconds

    @ObservationIgnored private let makeCode: () -> String
    @ObservationIgnored private let makePlayerId: () -> String
    /// Called with the owner's session once the room is built; HomeView opens
    /// the waiting room with it.
    @ObservationIgnored private let onCreate: (WaitingRoomSession) -> Void

    init(
        name: String = "",
        makeCode: @escaping () -> String = { LocalRoomCode.make() },
        makePlayerId: @escaping () -> String = { UUID().uuidString },
        onCreate: @escaping (WaitingRoomSession) -> Void = { _ in }
    ) {
        self.name = name
        self.makeCode = makeCode
        self.makePlayerId = makePlayerId
        self.onCreate = onCreate
    }

    var playerCountOptions: [Int] { Array(Room.minimumPlayers...Room.maximumPlayers) }

    var roundSecondsOptions: [Int] { Room.roundSecondsOptions }

    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canSubmit: Bool { !trimmedName.isEmpty }

    /// Builds the room with its creator as the ready owner and hands off the
    /// owner's session.
    func submit() {
        guard canSubmit else { return }
        let id = makePlayerId()
        let owner = Player(id: id, name: trimmedName, color: avatarColor, isOwner: true, isReady: true)
        let room = Room(code: makeCode(), capacity: playerCount, players: [owner], roundSeconds: roundSeconds)
        onCreate(WaitingRoomSession(room: room, role: .owner, currentPlayerId: id))
    }
}
