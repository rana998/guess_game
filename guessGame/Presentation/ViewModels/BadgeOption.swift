/// One choice in the tag picker, with what's left of the tag and whether it
/// can still be used this round.
struct BadgeOption: Identifiable, Hashable {
    let tag: ClueTag
    let caption: String
    let isEnabled: Bool

    var id: ClueTag { tag }
}
