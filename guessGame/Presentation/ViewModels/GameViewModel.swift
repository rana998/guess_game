import Foundation
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

    /// While the timer runs, and while an ended round waits to move on, the
    /// view calls `tick()` a few times a second.
    var isTicking: Bool {
        guard let game, !game.isFinished else { return false }
        return game.currentRound.isDescribing || game.currentRound.isEnded
    }

    /// Ends the round when its time is up, and opens the next round once an
    /// ended round's pause is over. Never while the leave alert is up, so the
    /// screen can't change underneath it.
    func tick() {
        let now = clock.refresh()
        guard let round = game?.currentRound else { return }
        if round.isDescribing {
            useCases.roundTimer.expireIfDue(now: now)
            return
        }
        guard round.isEnded, !isConfirmingLeave,
              now >= (round.endedAt ?? .distantPast).addingTimeInterval(Self.roundEndPause) else { return }
        continueAfterRound()
    }

    // MARK: - Round end

    /// How long an ended round stays on screen (the correct guess checked in
    /// the list, the board and timer frozen) before the next round opens. It
    /// stands in for the round-result screen still to be designed; once games
    /// span devices the host decides when to move on.
    static let roundEndPause: TimeInterval = 4

    /// The next describer's round, or out of the game after the last one.
    /// Called by `tick()` after `roundEndPause` for now; the round-result
    /// screen will call it instead.
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
