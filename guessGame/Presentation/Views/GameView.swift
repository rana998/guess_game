import SwiftUI

struct GameView: View {
    // @State (not @Bindable) is correct here: this view owns the @Observable
    // model's persistent storage, seeded only once from `init`, mirroring
    // @StateObject's behavior for ObservableObject.
    @State private var viewModel: GameViewModel

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.feedbackMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
            TextField("Enter a guess", text: $viewModel.guessInput)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isGameOver)
            Button("Guess") { viewModel.submitGuess() }
                .disabled(viewModel.isGameOver)
            Text("Attempts: \(viewModel.session?.attemptCount ?? 0)")
                .foregroundStyle(.secondary)
            Button("New Game") { viewModel.startNewGame() }
        }
        .padding()
        .onAppear {
            if viewModel.session == nil { viewModel.startNewGame() }
        }
    }
}
