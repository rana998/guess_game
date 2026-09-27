/// The tag a describer pins on an image they place: "?" is the main idea, the
/// cube an additional detail of it, "!" the secondary idea.
enum ClueTag: CaseIterable, Hashable {
    case mainIdea
    case detail
    case secondaryIdea

    /// "?" and cube images share the guessers' main-idea box; "!" has its own box.
    var belongsToMainIdea: Bool { self != .secondaryIdea }
}
