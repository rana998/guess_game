@testable import guessGame

final class MockGameRepository: GameRepository {
    var fixedTarget: Int
    private(set) var lastRequestedRange: ClosedRange<Int>?

    init(fixedTarget: Int) {
        self.fixedTarget = fixedTarget
    }

    func generateTarget(in range: ClosedRange<Int>) -> Int {
        lastRequestedRange = range
        return fixedTarget
    }
}
