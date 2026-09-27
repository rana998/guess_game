import Observation

/// The round flow for one viewer: which screen they see as the game moves
/// through its phases, the round's end and the next round, and leaving. Every
/// screen reads the same game, so one player's move redraws everyone's view.
@Observable
final class GameViewModel {
    /// Whose eyes the game is seen through. Each device has one player; the
    /// one-device build can switch between them (see `switchViewer`).
    private(set) var viewerId: String
    var isConfirmingLeave = false

    @ObservationIgnored private let useCases: GameUseCases
    @ObservationIgnored private let clock: GameClock
    @ObservationIgnored private let onExit: () -> Void
    @ObservationIgnored private var hasExited = false

    init(useCases: GameUseCases, viewerId: String, clock: GameClock, onExit: @escaping () -> Void) {
        self.useCases = useCases
        self.viewerId = viewerId
        self.clock = clock
        self.onExit = onExit
    }

    private var game: Game? { useCases.lifecycle.currentGame }

    // MARK: - Routing

    var screen: GameScreen? {
        guard let round = game?.currentRound else { return nil }
        let isDescriber = round.describerId == viewerId
        switch round.phase {
        case .choosingWord: return isDescriber ? .difficultyPicker : .waitingForWord
        case .wordDrawn: return isDescriber ? .wordCard : .waitingForWord
        case .describing, .ended: return isDescriber ? .describerBoard : .guesserBoard
        }
    }

    var screenIdentity: GameScreenIdentity? {
        guard let game, let screen else { return nil }
        return GameScreenIdentity(roundIndex: game.currentRound.index, viewerId: viewerId, screen: screen)
    }

    // MARK: - Time

    /// While the timer runs, the view calls `tick()` a few times a second.
    var isTicking: Bool { game?.currentRound.isDescribing == true }

    func tick() {
        useCases.roundTimer.expireIfDue(now: clock.refresh())
    }

    // MARK: - Round end

    var roundEnded: RoundEndedCard.Model? {
        guard let game, let reason = game.currentRound.endReason else { return nil }
        let round = game.currentRound
        let title: String
        let pointsLine: String
        switch reason {
        case .guessed(let winnerId):
            let winnerName = game.player(id: winnerId)?.name ?? ""
            title = Strings.RoundEnded.correctGuessTitle(name: winnerName)
            pointsLine = Strings.RoundEnded.points(
                guesser: winnerName,
                guesserPoints: round.awardedPoints[winnerId] ?? 0,
                describer: game.describer?.name ?? "",
                describerPoints: round.awardedPoints[round.describerId] ?? 0
            )
        case .timeUp:
            title = Strings.RoundEnded.timeUp
            pointsLine = Strings.RoundEnded.noPoints
        case .endedByDescriber:
            title = Strings.RoundEnded.endedByDescriber
            pointsLine = Strings.RoundEnded.noPoints
        }
        return RoundEndedCard.Model(
            title: title,
            wordLine: Strings.RoundEnded.wordLine(word: round.word ?? ""),
            pointsLine: pointsLine,
            buttonTitle: game.isLastRound ? Strings.RoundEnded.finishGame : Strings.RoundEnded.nextRound
        )
    }

    /// The next describer's round, or out of the game after the last one.
    func continueAfterRound() {
        useCases.lifecycle.advanceToNextRound()
        if game?.isFinished == true {
            exitOnce()
        }
    }

    // MARK: - Leaving

    func requestLeave() {
        isConfirmingLeave = true
    }

    func confirmLeave() {
        exitOnce()
    }

    private func exitOnce() {
        guard !hasExited else { return }
        hasExited = true
        useCases.lifecycle.leave()
        onExit()
    }

    // MARK: - Viewer

    var viewerAvatar: AvatarModel? { game?.player(id: viewerId).map(AvatarModel.init(player:)) }

    var viewerChoices: [ViewerChoice] {
        guard let game else { return [] }
        return game.players.map { player in
            let isDescriber = player.id == game.currentRound.describerId
            return ViewerChoice(id: player.id, title: player.name + (isDescriber ? Strings.GameDebug.describerSuffix : ""))
        }
    }

    func switchViewer(to playerId: String) {
        guard game?.player(id: playerId) != nil else { return }
        viewerId = playerId
    }

    // MARK: - Screens

    func makeDifficultyPickerViewModel() -> DifficultyPickerViewModel {
        DifficultyPickerViewModel(useCases: useCases, viewerId: viewerId, clock: clock)
    }

    func makeWordCardViewModel() -> WordCardViewModel {
        WordCardViewModel(useCases: useCases, viewerId: viewerId, clock: clock)
    }

    func makeWaitingForWordViewModel() -> WaitingForWordViewModel {
        WaitingForWordViewModel(useCases: useCases, viewerId: viewerId, clock: clock)
    }

    func makeDescriberBoardViewModel() -> DescriberBoardViewModel {
        DescriberBoardViewModel(useCases: useCases, viewerId: viewerId, clock: clock)
    }

    func makeGuesserBoardViewModel() -> GuesserBoardViewModel {
        GuesserBoardViewModel(useCases: useCases, viewerId: viewerId, clock: clock)
    }
}
