import Foundation

/// Everything the round's describer does: draw a word, start the timer, tag
/// images and end the round early. Each call is refused for anyone else.
protocol DescriberTurnUseCase {
    @discardableResult func drawWord(difficulty: Difficulty, by playerId: String) -> Bool
    @discardableResult func startDescribing(by playerId: String, now: Date) -> Bool
    @discardableResult func placeMark(_ tag: ClueTag, onTile tileIndex: Int, by playerId: String) -> ClueMarkResult
    @discardableResult func endRound(by playerId: String, now: Date) -> Bool
}
