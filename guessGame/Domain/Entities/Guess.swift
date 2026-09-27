/// One submitted guess (handoff `roundState.guesses[]`). `id` is its position in
/// the round's guess list; `text` is what the player typed, trimmed.
struct Guess: Identifiable, Hashable {
    let id: Int
    let playerId: String
    let text: String
    let isCorrect: Bool
}
