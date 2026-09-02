final class GameRepositoryImpl: GameRepository {
    private let dataSource: InMemoryGameDataSource

    init(dataSource: InMemoryGameDataSource) {
        self.dataSource = dataSource
    }

    func generateTarget(in range: ClosedRange<Int>) -> Int {
        dataSource.randomNumber(in: range)
    }
}
