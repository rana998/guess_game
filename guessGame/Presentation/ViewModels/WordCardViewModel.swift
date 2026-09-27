import Observation

/// The describer's word reveal, and the button that starts the timer.
@Observable
final class WordCardViewModel {
    @ObservationIgnored private let useCases: GameUseCases
    @ObservationIgnored private let viewerId: String
    @ObservationIgnored private let clock: GameClock

    init(useCases: GameUseCases, viewerId: String, clock: GameClock) {
        self.useCases = useCases
        self.viewerId = viewerId
        self.clock = clock
    }

    private var round: Round? { useCases.lifecycle.currentGame?.currentRound }

    var wordText: String { round?.word ?? "" }

    /// "متوسط +2"
    var chipText: String {
        guard let difficulty = round?.difficulty else { return "" }
        return Strings.Difficulties.chip(name: difficulty.title, points: ScoringRules.guesserPoints(for: difficulty))
    }

    /// The checklist line for each tag, with the cube limit from the rules.
    func ruleText(for tag: ClueTag) -> String {
        switch tag {
        case .mainIdea: Strings.WordCard.mainIdeaRule
        case .detail: Strings.WordCard.detailRule(limit: ClueMarkRules.limit(for: .detail))
        case .secondaryIdea: Strings.WordCard.secondaryRule
        }
    }

    @discardableResult
    func startDescribing() -> Bool {
        useCases.describerTurn.startDescribing(by: viewerId, now: clock.refresh())
    }
}
