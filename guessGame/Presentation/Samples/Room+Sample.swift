#if DEBUG
/// Example rooms for previews and screenshots only — the shipping app never
/// reads them. `sample`'s first three players are the Enter Name mockup's;
/// `sampleLobby` holds the waiting-room mockups' six.
extension Room {
    static func sample(playerCount: Int = 3, capacity: Int = 6, code: String = "8701") -> Room {
        let people: [(name: String, color: PlayerColor)] = [
            ("نهى", .green), ("سلمان", .teal), ("لمى", .gold),
            ("خالد", .blue), ("ريم", .purple), ("هند", .pink),
        ]
        let players = people.prefix(max(0, min(playerCount, people.count))).enumerated().map { index, person in
            Player(id: "sample-\(index)", name: person.name, color: person.color, isOwner: index == 0)
        }
        return Room(code: code, capacity: capacity, players: players)
    }

    /// The waiting-room mockups' six players, in reading order. Only نهى is the owner.
    static func sampleLobby(capacity: Int = 6) -> Room {
        let people: [(name: String, color: PlayerColor, isReady: Bool)] = [
            ("نهى", .green, true), ("سلمان", .teal, true), ("عبدالله", .blue, false),
            ("ربى", .pink, true), ("فهد", .purple, false), ("لمى", .gold, true),
        ]
        let players = people.prefix(max(0, capacity)).enumerated().map { index, person in
            Player(id: "lobby-\(index)", name: person.name, color: person.color, isOwner: index == 0, isReady: person.isReady)
        }
        return Room(code: "8701", capacity: capacity, players: players, roundSeconds: 60)
    }
}
#endif
