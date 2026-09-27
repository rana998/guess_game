import SwiftUI

/// The round flow's host: shows the viewer's screen for the round's phase,
/// runs the round timer, moves on a short pause after a round ends and asks
/// before leaving. Screens get a fresh state (typed guess, open picker)
/// whenever the round, viewer or screen changes.
struct GameView: View {
    @State private var viewModel: GameViewModel

    init(viewModel: GameViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.paper
            screenLayer
                .id(viewModel.screenIdentity)
            #if DEBUG
            if let viewer = viewModel.viewerAvatar {
                ViewerSwitcher(viewer: viewer, choices: viewModel.viewerChoices) { playerId in
                    viewModel.switchViewer(to: playerId)
                }
                .padding(.top, 4)
            }
            #endif
        }
        // Not the keyboard's area: the guess field has to stay above it.
        .ignoresSafeArea(.container)
        // The round screens' sizes are measured and fixed, like the waiting room's.
        .dynamicTypeSize(.large)
        .navigationBarHidden(true)
        .alert(Strings.LeaveGame.title, isPresented: $viewModel.isConfirmingLeave) {
            Button(Strings.LeaveGame.cancel, role: .cancel) {}
            Button(Strings.LeaveGame.confirm, role: .destructive) { viewModel.confirmLeave() }
        } message: {
            Text(Strings.LeaveGame.message)
        }
        .task(id: viewModel.isTicking) {
            guard viewModel.isTicking else { return }
            while !Task.isCancelled && viewModel.isTicking {
                viewModel.tick()
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    @ViewBuilder
    private var screenLayer: some View {
        switch viewModel.screen {
        case .difficultyPicker:
            DifficultyPickerView(viewModel: viewModel.makeDifficultyPickerViewModel())
        case .wordCard:
            WordCardView(viewModel: viewModel.makeWordCardViewModel())
        case .waitingForWord:
            WaitingForWordView(viewModel: viewModel.makeWaitingForWordViewModel())
        case .describerBoard:
            DescriberBoardView(viewModel: viewModel.makeDescriberBoardViewModel()) { viewModel.requestLeave() }
        case .guesserBoard:
            GuesserBoardView(viewModel: viewModel.makeGuesserBoardViewModel()) { viewModel.requestLeave() }
        case nil:
            Color.paper
        }
    }
}

#if DEBUG
#Preview("Game, as a guesser", traits: .landscapeLeft) {
    GameView(viewModel: GameViewModel(
        useCases: .preview(seededWith: .sample(phase: .describing, marks: [ClueMark(tileIndex: 3, tag: .mainIdea)])),
        viewerId: "lobby-3",
        clock: GameClock(currentDate: { Game.sampleNow }),
        onExit: {}
    ))
}
#endif
