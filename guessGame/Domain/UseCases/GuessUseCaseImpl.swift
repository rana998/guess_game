import Foundation

struct GuessUseCaseImpl: GuessUseCase {
    let repository: GameRepository
    let matcher: GuessMatcher

    @discardableResult
    func submit(_ text: String, by playerId: String, now: Date) -> GuessResult {
        guard var game = repository.game else { return .rejected(.noGame) }
        var round = game.currentRound
        guard round.isDescribing else { return .rejected(.notDescribing) }
        // The clock may pass the end a moment before the timer check records it.
        if let endsAt = round.endsAt, now >= endsAt { return .rejected(.timeUp) }
        guard game.player(id: playerId) != nil else { return .rejected(.unknownPlayer) }
        guard playerId != round.describerId else { return .rejected(.describerCannotGuess) }
        guard round.hasAnyMark else { return .rejected(.noClueYet) }
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return .rejected(.empty) }
        guard let word = round.word, let difficulty = round.difficulty else { return .rejected(.notDescribing) }

        let isCorrect = matcher.matches(trimmedText, word: word)
        round.guesses.append(Guess(id: round.guesses.count, playerId: playerId, text: trimmedText, isCorrect: isCorrect))
        if isCorrect {
            let guesserPoints = ScoringRules.guesserPoints(for: difficulty)
            game.scores[playerId, default: 0] += guesserPoints
            game.scores[round.describerId, default: 0] += ScoringRules.describerPoints
            round.awardedPoints = [playerId: guesserPoints, round.describerId: ScoringRules.describerPoints]
            round.phase = .ended(.guessed(winnerId: playerId))
            round.endedAt = now
        }
        game.currentRound = round
        repository.save(game)
        return isCorrect ? .correct : .incorrect
    }
}
