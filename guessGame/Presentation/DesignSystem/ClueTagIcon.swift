import SwiftUI

/// A tag's badge art ("?", cube, "!"). `pin` is the size pinned on a tile's
/// corner and shown in How to Play; `legend` the small one beside text;
/// `counter` the cube counter's; `option` the tag picker's. Decorative: the text beside it names the tag.
struct ClueTagIcon: View {
    enum Size {
        case legend
        case counter
        case pin
        case option

        var scale: CGFloat {
            switch self {
            case .legend: 0.62
            case .counter: 0.8
            case .pin: 1
            case .option: 1.35
            }
        }
    }

    let tag: ClueTag
    var size: Size = .pin

    var body: some View {
        let frame = Self.pinFrame(for: tag)
        Image(tag.assetName)
            .resizable()
            .interpolation(.high)
            .frame(width: frame.width * size.scale, height: frame.height * size.scale)
            .accessibilityHidden(true)
    }

    /// The How to Play frames, which put each badge's ink at the mockups' size.
    static func pinFrame(for tag: ClueTag) -> CGSize {
        switch tag {
        case .mainIdea: InfoCard.Icon.question.size
        case .detail: InfoCard.Icon.cube.size
        case .secondaryIdea: InfoCard.Icon.exclaim.size
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        ForEach(ClueTag.allCases, id: \.self) { tag in
            VStack {
                ClueTagIcon(tag: tag, size: .legend)
                ClueTagIcon(tag: tag)
                ClueTagIcon(tag: tag, size: .option)
            }
        }
    }
    .padding(24)
    .background(Color.paper)
}
#endif
