#if DEBUG
/// Example rooms for previews and screenshots only — the shipping app never
/// reads them. The first three players are the Enter Name mockup's.
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
}
#endif
