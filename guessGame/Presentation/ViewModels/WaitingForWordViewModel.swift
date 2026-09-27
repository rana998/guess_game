import Observation

/// What a guesser sees while the describer picks and reads the word: who's
/// describing, when the viewer's own turn comes, and who's guessing.
@Observable
final class WaitingForWordViewModel {
    @ObservationIgnored private let useCases: GameUseCases
    @ObservationIgnored private let viewerId: String

    init(useCases: GameUseCases, viewerId: String, clock: GameClock) {
        self.useCases = useCases
        self.viewerId = viewerId
    }

    private var game: Game? { useCases.lifecycle.currentGame }

    var describerAvatar: AvatarModel? { game?.describer.map(AvatarModel.init(player:)) }

    var describerPillText: String { Strings.WaitingForWord.describerChoosing(name: game?.describer?.name ?? "") }

    var message: String { Strings.WaitingForWord.message(describerName: game?.describer?.name ?? "") }

    /// nil once the viewer has no describing turn left.
    var turnBadgeText: String? {
        game?.roundsUntilTurn(of: viewerId).map { roundsAway in Strings.WaitingForWord.turnBadge(roundsAway: roundsAway) }
    }

    var guesserAvatars: [AvatarModel] { game?.guessers.map(AvatarModel.init(player:)) ?? [] }

    var guessersCountText: String { Strings.WaitingForWord.guessersReady(count: game?.guessers.count ?? 0) }
}
