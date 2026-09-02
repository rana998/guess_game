protocol StartGameUseCase {
    func execute(range: ClosedRange<Int>) -> GameSession
}
