import SwiftUI

/// One picture tile, blank until real images exist: on the describer's board
/// (tinted once tagged), in the guessers' main- or secondary-idea box, or as
/// the tag picker's preview. A tagged tile carries its tag on its top-left corner.
struct ClueTile: View {
    struct Model: Identifiable, Hashable {
        /// The board tile the image sits on.
        let id: Int
        let tag: ClueTag?
        let accessibilityLabel: String
        let accessibilityValue: String
    }

    enum Style {
        case board
        case mainIdea
        case secondaryIdea
        case preview

        var side: CGFloat { self == .preview ? 57 : 84 }
    }

    let model: Model
    let style: Style

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .circular)
        shape
            .fill(fill)
            .overlay(shape.strokeBorder(border, lineWidth: 3))
            .frame(width: style.side, height: style.side)
            .hardShadow(in: shape, offset: CGSize(width: 3, height: 3))
            .overlay { pin }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(model.accessibilityLabel)
            .accessibilityValue(model.accessibilityValue)
    }

    // The mockups pin the tag on the physical top-left corner in every layout
    // direction, so this layer is laid out left to right.
    @ViewBuilder
    private var pin: some View {
        if let tag = model.tag, style != .preview {
            let iconSize = ClueTagIcon.pinFrame(for: tag)
            ZStack(alignment: .topLeading) {
                Color.clear
                ClueTagIcon(tag: tag)
                    .offset(x: 3 - iconSize.width / 2, y: 5 - iconSize.height / 2)
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }

    private var fill: Color {
        guard style == .board, let tag = model.tag else { return .white }
        return tag.belongsToMainIdea ? .tintLime : .tintRed
    }

    private var border: Color {
        switch style {
        case .board, .preview: .black
        case .mainIdea: .brandLimeDeep
        case .secondaryIdea: .brandRed
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        ClueTile(model: .init(id: 0, tag: nil, accessibilityLabel: "", accessibilityValue: ""), style: .board)
        ClueTile(model: .init(id: 1, tag: .detail, accessibilityLabel: "", accessibilityValue: ""), style: .board)
        ClueTile(model: .init(id: 2, tag: .mainIdea, accessibilityLabel: "", accessibilityValue: ""), style: .mainIdea)
        ClueTile(model: .init(id: 3, tag: .secondaryIdea, accessibilityLabel: "", accessibilityValue: ""), style: .secondaryIdea)
        ClueTile(model: .init(id: 4, tag: nil, accessibilityLabel: "", accessibilityValue: ""), style: .preview)
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
