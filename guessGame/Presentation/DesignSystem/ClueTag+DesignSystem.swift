/// How each image tag is named and drawn. The tags themselves are Domain.
extension ClueTag {
    var title: String {
        switch self {
        case .mainIdea: Strings.ClueTags.mainIdea
        case .detail: Strings.ClueTags.detail
        case .secondaryIdea: Strings.ClueTags.secondaryIdea
        }
    }

    var assetName: String {
        switch self {
        case .mainIdea: "badge-question"
        case .detail: "badge-cube"
        case .secondaryIdea: "badge-exclaim"
        }
    }
}
