import SwiftUI
import XCTest
@testable import guessGame

/// Renders each round screen in its mockup's state for comparing against the
/// mockups by hand. The screens render on their own, without GameView's
/// development-only viewer switcher over them; the round-ended card, which
/// has no mockup, renders through GameView.
@MainActor
final class GameSnapshotTests: XCTestCase {
    private let clock = GameClock(currentDate: { Game.sampleNow })

    private func render<V: View>(_ view: V, as name: String) throws {
        let directory = try SnapshotRenderer.outputDirectory()
        let data = try SnapshotRenderer.render(view)
        try data.write(to: directory.appendingPathComponent("Game-\(name).png"))
    }

    func testRenderWaitingForWord() throws {
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .choosingWord))
        try render(WaitingForWordView(viewModel: WaitingForWordViewModel(useCases: useCases, viewerId: "lobby-2", clock: clock)), as: "waitingForWord")
    }

    func testRenderDifficultyPicker() throws {
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .choosingWord))
        try render(DifficultyPickerView(viewModel: DifficultyPickerViewModel(useCases: useCases, viewerId: "lobby-0", clock: clock)), as: "difficulty")
    }

    func testRenderWordCard() throws {
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .wordDrawn))
        try render(WordCardView(viewModel: WordCardViewModel(useCases: useCases, viewerId: "lobby-0", clock: clock)), as: "wordCard")
    }

    /// The describer and picker mockups' board: the "?" and "!" used, three cubes (7/10 left).
    private static let boardMarks = [
        ClueMark(tileIndex: 5, tag: .detail),
        ClueMark(tileIndex: 14, tag: .secondaryIdea),
        ClueMark(tileIndex: 19, tag: .mainIdea),
        ClueMark(tileIndex: 26, tag: .detail),
        ClueMark(tileIndex: 30, tag: .detail),
    ]

    func testRenderDescriberBoard() throws {
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .describing, marks: Self.boardMarks))
        let viewModel = DescriberBoardViewModel(useCases: useCases, viewerId: "lobby-0", clock: clock)
        try render(DescriberBoardView(viewModel: viewModel, onBack: {}), as: "describerBoard")
    }

    /// The picker mockup still offers "!", so this board has no "!" yet.
    func testRenderBadgePicker() throws {
        let marks = Self.boardMarks.filter { mark in mark.tag != .secondaryIdea }
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .describing, marks: marks))
        let viewModel = DescriberBoardViewModel(useCases: useCases, viewerId: "lobby-0", clock: clock)
        viewModel.selectTile(6)
        try render(DescriberBoardView(viewModel: viewModel, onBack: {}), as: "badgePicker")
    }

    func testRenderGuesserEmpty() throws {
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .describing))
        let viewModel = GuesserBoardViewModel(useCases: useCases, viewerId: "lobby-3", clock: clock)
        try render(GuesserBoardView(viewModel: viewModel, onBack: {}), as: "guesserEmpty")
    }

    /// The guesser mockup's round: "?" then four cubes, the "!", four wrong
    /// guesses and the right one.
    func testRenderGuesser() throws {
        let marks = [
            ClueMark(tileIndex: 19, tag: .mainIdea),
            ClueMark(tileIndex: 5, tag: .detail),
            ClueMark(tileIndex: 26, tag: .detail),
            ClueMark(tileIndex: 14, tag: .secondaryIdea),
            ClueMark(tileIndex: 30, tag: .detail),
            ClueMark(tileIndex: 2, tag: .detail),
        ]
        let guesses = [
            Guess(id: 0, playerId: "lobby-3", text: "حصان", isCorrect: false),
            Guess(id: 1, playerId: "lobby-4", text: "حيوان كبير", isCorrect: false),
            Guess(id: 2, playerId: "lobby-5", text: "زرافة", isCorrect: false),
            Guess(id: 3, playerId: "lobby-1", text: "فرس النهر", isCorrect: false),
            Guess(id: 4, playerId: "lobby-2", text: "وحيد القرن", isCorrect: true),
        ]
        let useCases = GameUseCases.preview(seededWith: .sample(phase: .ended(.guessed(winnerId: "lobby-2")), marks: marks, guesses: guesses))
        let viewModel = GuesserBoardViewModel(useCases: useCases, viewerId: "lobby-3", clock: clock)
        try render(GuesserBoardView(viewModel: viewModel, onBack: {}), as: "guesser")
    }

    func testRenderRoundEnded() throws {
        let guesses = [Guess(id: 0, playerId: "lobby-2", text: "وحيد القرن", isCorrect: true)]
        var game = Game.sample(phase: .ended(.guessed(winnerId: "lobby-2")), marks: [ClueMark(tileIndex: 19, tag: .mainIdea)], guesses: guesses)
        game.currentRound.awardedPoints = ["lobby-2": 2, "lobby-0": 1]
        let viewModel = GameViewModel(useCases: .preview(seededWith: game), viewerId: "lobby-3", clock: clock, onExit: {})
        try render(GameView(viewModel: viewModel), as: "roundEnded")
    }
}
