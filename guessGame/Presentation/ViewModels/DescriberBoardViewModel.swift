import Observation

/// The describer's board: tag images on the 8×4 grid through the tag picker,
/// watch the cube budget and the time, or end the round early. Every tag goes
/// through the describer-turn use case, which enforces the caps.
@Observable
final class DescriberBoardViewModel {
    /// The tile whose tag picker is open.
    private(set) var pickerTileIndex: Int?

    @ObservationIgnored private let useCases: GameUseCases
    @ObservationIgnored private let viewerId: String
    @ObservationIgnored private let clock: GameClock

    init(useCases: GameUseCases, viewerId: String, clock: GameClock) {
        self.useCases = useCases
        self.viewerId = viewerId
        self.clock = clock
    }

    private var game: Game? { useCases.lifecycle.currentGame }

    private var round: Round? { game?.currentRound }

    var wordText: String { round?.word ?? "" }

    var timerText: String {
        guard let game else { return CountdownFormatter.text(seconds: 0) }
        return CountdownFormatter.text(for: game, at: clock.now)
    }

    /// "7/10": cubes left this round.
    var detailCounterText: String {
        let remainingDetails = round.map { currentRound in ClueMarkRules.remaining(.detail, in: currentRound) } ?? 0
        return Strings.DescriberBoard.detailCounter(remaining: remainingDetails, limit: ClueMarkRules.limit(for: .detail))
    }

    var tiles: [ClueTile.Model] {
        (0..<Round.tileCount).map { tileIndex in tileModel(at: tileIndex) }
    }

    /// Only an untagged tile, while describing and with a tag left to give.
    func isTileEnabled(_ tile: ClueTile.Model) -> Bool {
        guard let round, round.isDescribing, tile.tag == nil else { return false }
        return ClueMarkRules.hasAnyRemaining(in: round)
    }

    // MARK: - Tag picker

    /// Closes by itself when the round ends under it.
    var isPickerPresented: Bool { pickerTileIndex != nil && round?.isDescribing == true }

    var pickerPreview: ClueTile.Model? { pickerTileIndex.map { tileIndex in tileModel(at: tileIndex) } }

    /// "الصورة 7 من 32"
    var pickerSubtitle: String {
        Strings.BadgePicker.subtitle(number: (pickerTileIndex ?? 0) + 1, total: Round.tileCount)
    }

    var pickerOptions: [BadgeOption] {
        guard let round else { return [] }
        return ClueTag.allCases.map { tag in
            let remaining = ClueMarkRules.remaining(tag, in: round)
            let caption: String = switch tag {
            case .mainIdea: remaining > 0 ? Strings.BadgePicker.mainIdeaAvailable : Strings.BadgePicker.used
            case .detail: Strings.DescriberBoard.detailCounter(remaining: remaining, limit: ClueMarkRules.limit(for: .detail))
            case .secondaryIdea: remaining > 0 ? Strings.BadgePicker.secondaryAvailable : Strings.BadgePicker.used
            }
            return BadgeOption(tag: tag, caption: caption, isEnabled: remaining > 0)
        }
    }

    func selectTile(_ tileIndex: Int) {
        guard let round, round.isDescribing, round.mark(onTile: tileIndex) == nil,
              ClueMarkRules.hasAnyRemaining(in: round) else { return }
        pickerTileIndex = tileIndex
    }

    /// Tags the picker's tile. A refused tag (e.g. its cap is reached) leaves
    /// the picker open.
    @discardableResult
    func choose(_ tag: ClueTag) -> ClueMarkResult {
        guard let pickerTileIndex else { return .rejected(.tileOutOfRange) }
        let result = useCases.describerTurn.placeMark(tag, onTile: pickerTileIndex, by: viewerId)
        if result == .placed {
            self.pickerTileIndex = nil
        }
        return result
    }

    func cancelPicker() {
        pickerTileIndex = nil
    }

    /// Only while the timer runs; an ended round stays on screen until the next one.
    var canEndRound: Bool { round?.isDescribing == true }

    @discardableResult
    func endRound() -> Bool {
        useCases.describerTurn.endRound(by: viewerId, now: clock.refresh())
    }

    private func tileModel(at tileIndex: Int) -> ClueTile.Model {
        let tag = round?.mark(onTile: tileIndex)?.tag
        return ClueTile.Model(
            id: tileIndex,
            tag: tag,
            accessibilityLabel: Strings.DescriberBoard.tileLabel(number: tileIndex + 1),
            accessibilityValue: tag?.title ?? Strings.DescriberBoard.untagged
        )
    }
}
