import Observation

/// A guesser's view of the round: the describer's images arriving in the
/// main- and secondary-idea boxes in the order they're tagged, everyone's
/// guesses, and the field to guess in. Guessing opens with the first image.
@Observable
final class GuesserBoardViewModel {
    var typedGuess = ""

    @ObservationIgnored private let useCases: GameUseCases
    @ObservationIgnored private let viewerId: String
    @ObservationIgnored private let clock: GameClock

    /// The main-idea box shows this many places before it starts scrolling.
    static let visibleMainSlotCount = 5

    init(useCases: GameUseCases, viewerId: String, clock: GameClock) {
        self.useCases = useCases
        self.viewerId = viewerId
        self.clock = clock
    }

    private var game: Game? { useCases.lifecycle.currentGame }

    private var round: Round? { game?.currentRound }

    // MARK: - Header

    /// "الجولة 3/6"
    var roundText: String {
        guard let game else { return "" }
        return Strings.GuesserBoard.round(number: game.currentRound.index + 1, total: game.roundCount)
    }

    var timerText: String {
        guard let game else { return CountdownFormatter.text(seconds: 0) }
        return CountdownFormatter.text(for: game, at: clock.now)
    }

    var describerAvatar: AvatarModel? { game?.describer.map(AvatarModel.init(player:)) }

    var guesserAvatars: [AvatarModel] { game?.guessers.map(AvatarModel.init(player:)) ?? [] }

    var isRoundOver: Bool { round?.isEnded ?? true }

    // MARK: - Guesses

    /// Oldest first, as a running list.
    var guessRows: [GuessRow.Model] {
        guard let game else { return [] }
        return game.currentRound.guesses.map { guess in
            let name = game.player(id: guess.playerId)?.name ?? ""
            let label = Strings.GuesserBoard.guessLabel(name: name, text: guess.text)
            return GuessRow.Model(
                id: guess.id,
                playerName: name,
                text: guess.text,
                isCorrect: guess.isCorrect,
                accessibilityLabel: guess.isCorrect ? "\(label)، \(Strings.GuesserBoard.correct)" : label
            )
        }
    }

    var isGuessListEmpty: Bool { round?.guesses.isEmpty ?? true }

    var emptySubtitle: String {
        round?.hasAnyMark == true ? Strings.GuesserBoard.emptyReadySubtitle : Strings.GuesserBoard.emptySubtitle
    }

    var canSubmit: Bool {
        guard let round, round.isDescribing, round.hasAnyMark, round.describerId != viewerId else { return false }
        return !typedGuess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Clears the field once the guess is recorded; a refused guess stays typed.
    @discardableResult
    func submit() -> GuessResult? {
        guard canSubmit else { return nil }
        let result = useCases.guess.submit(typedGuess, by: viewerId, now: clock.refresh())
        if case .rejected = result { return result }
        typedGuess = ""
        return result
    }

    var guessCount: Int { round?.guesses.count ?? 0 }

    var lastGuessId: Int? { round?.guesses.last?.id }

    /// Read out for other players' guesses; the viewer knows their own.
    var latestGuessAnnouncement: String? {
        guard let lastGuess = round?.guesses.last, lastGuess.playerId != viewerId else { return nil }
        return guessRows.last?.accessibilityLabel
    }

    // MARK: - Clue boxes

    /// The "?" and cube images, in the order the describer tagged them.
    var mainSlots: [ClueTile.Model] {
        (round?.mainIdeaMarks ?? []).enumerated().map { position, mark in slotModel(for: mark, number: position + 1) }
    }

    /// Dashed places filling the box's first five until images arrive.
    var placeholderSlotCount: Int { max(0, Self.visibleMainSlotCount - mainSlots.count) }

    var lastMainSlotId: Int? { round?.mainIdeaMarks.last?.tileIndex }

    var mainBoxCaption: String? { mainSlots.isEmpty ? Strings.GuesserBoard.waitingFirstTile : nil }

    var secondaryTile: ClueTile.Model? { round?.secondaryIdeaMark.map { mark in slotModel(for: mark, number: 1) } }

    /// Only until the first image arrives.
    var bottomCaption: String? {
        guard let game, !game.currentRound.hasAnyMark else { return nil }
        return Strings.GuesserBoard.waitingForFirstTile(name: game.describer?.name ?? "")
    }

    var markCount: Int { round?.marks.count ?? 0 }

    var latestMarkAnnouncement: String? {
        round?.marks.last.map { mark in Strings.GuesserBoard.newClueAnnouncement(tagName: mark.tag.title) }
    }

    private func slotModel(for mark: ClueMark, number: Int) -> ClueTile.Model {
        ClueTile.Model(
            id: mark.tileIndex,
            tag: mark.tag,
            accessibilityLabel: Strings.GuesserBoard.slotLabel(number: number),
            accessibilityValue: mark.tag.title
        )
    }
}
