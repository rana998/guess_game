import SwiftUI

@main
struct guessGameApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: Self.makeGameViewModel())
        }
    }

    /// Composition root: the only place in the app allowed to know about all three layers.
    private static func makeGameViewModel() -> GameViewModel {
        let dataSource = InMemoryGameDataSource()
        let repository = GameRepositoryImpl(dataSource: dataSource)
        let startGameUseCase = StartGameUseCaseImpl(repository: repository)
        let makeGuessUseCase = MakeGuessUseCaseImpl()
        return GameViewModel(startGameUseCase: startGameUseCase, makeGuessUseCase: makeGuessUseCase)
    }
}
