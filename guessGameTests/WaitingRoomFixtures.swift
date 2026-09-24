@testable import guessGame

/// The waiting-room mockups' lobby for the snapshot tests: the same six players,
/// states, ids and code as the DEBUG `Room.sampleLobby`.
enum WaitingRoomFixtures {
    static func lobbyRoom(capacity: Int = 6) -> Room {
        let people: [(name: String, color: PlayerColor, isReady: Bool)] = [
            ("نهى", .green, true), ("سلمان", .teal, true), ("عبدالله", .blue, false),
            ("ربى", .pink, true), ("فهد", .purple, false), ("لمى", .gold, true),
        ]
        let players = people.prefix(max(0, capacity)).enumerated().map { index, person in
            Player(id: "lobby-\(index)", name: person.name, color: person.color, isOwner: index == 0, isReady: person.isReady)
        }
        return Room(code: "8701", capacity: capacity, players: players, roundSeconds: 60)
    }

    static var ownerSession: WaitingRoomSession {
        WaitingRoomSession(room: lobbyRoom(), role: .owner, currentPlayerId: "lobby-0")
    }

    static var participantSession: WaitingRoomSession {
        WaitingRoomSession(room: lobbyRoom(), role: .participant, currentPlayerId: "lobby-3")
    }

    /// Two players in a room for four: start disabled, two empty seats.
    static var smallOwnerSession: WaitingRoomSession {
        var room = lobbyRoom(capacity: 4)
        room.players = Array(room.players.prefix(2))
        return WaitingRoomSession(room: room, role: .owner, currentPlayerId: "lobby-0")
    }
}
