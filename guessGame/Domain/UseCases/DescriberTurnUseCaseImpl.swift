import Foundation

struct DescriberTurnUseCaseImpl: DescriberTurnUseCase {
    let repository: GameRepository
    let wordRepository: WordRepository
    let wordPicker: RandomIndexPicker

    /// Draws a word not yet used this game, falling back to the whole level once
    /// every word in it has come up.
    @discardableResult
    func drawWord(difficulty: Difficulty, by playerId: String) -> Bool {
        guard var game = repository.game,
              game.currentRound.phase == .choosingWord,
              game.currentRound.describerId == playerId else { return false }
        let levelWords = wordRepository.words(for: difficulty)
        let unusedWords = levelWords.filter { word in !game.usedWords.contains(word) }
        let candidates = unusedWords.isEmpty ? levelWords : unusedWords
        guard let wordIndex = wordPicker.index(below: candidates.count) else { return false }
        let word = candidates[wordIndex]
        game.currentRound.word = word
        game.currentRound.difficulty = difficulty
        game.currentRound.phase = .wordDrawn
        game.usedWords.insert(word)
        repository.save(game)
        return true
    }

    @discardableResult
    func startDescribing(by playerId: String, now: Date) -> Bool {
        guard var game = repository.game,
              game.currentRound.phase == .wordDrawn,
              game.currentRound.describerId == playerId else { return false }
        game.currentRound.endsAt = now.addingTimeInterval(TimeInterval(game.roundSeconds))
        game.currentRound.phase = .describing
        repository.save(game)
        return true
    }

    @discardableResult
    func placeMark(_ tag: ClueTag, onTile tileIndex: Int, by playerId: String) -> ClueMarkResult {
        guard var game = repository.game else { return .rejected(.noGame) }
        guard game.currentRound.describerId == playerId else { return .rejected(.notDescriber) }
        if let rejection = ClueMarkRules.rejection(placing: tag, onTile: tileIndex, in: game.currentRound) {
            return .rejected(rejection)
        }
        game.currentRound.marks.append(ClueMark(tileIndex: tileIndex, tag: tag))
        repository.save(game)
        return .placed
    }

    @discardableResult
    func endRound(by playerId: String, now: Date) -> Bool {
        guard var game = repository.game,
              game.currentRound.isDescribing,
              game.currentRound.describerId == playerId else { return false }
        game.currentRound.phase = .ended(.endedByDescriber)
        game.currentRound.endedAt = now
        repository.save(game)
        return true
    }
}
