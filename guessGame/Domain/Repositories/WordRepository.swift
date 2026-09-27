/// The words a describer can draw at each difficulty.
protocol WordRepository {
    func words(for difficulty: Difficulty) -> [String]
}
