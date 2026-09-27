/// How hard the describer's word is; harder words score more (see `ScoringRules`).
/// Declared in reading order: easy sits on the physical right of the picker.
enum Difficulty: CaseIterable, Hashable {
    case easy
    case medium
    case hard
}
