import SwiftUI

/// One 56×70pt box of the room-code row. Its look comes entirely from `Style`,
/// which the caller derives from the entry state and the box's position.
struct CodeDigitBox: View {
    enum Style: Equatable {
        /// Holds a typed digit.
        case filled
        /// The next box to fill: yellow, with a caret instead of a digit.
        case active
        /// Waiting to be filled: dashed outline.
        case empty
        /// The code was rejected: red tint and outline.
        case error
        /// The room can't be joined: muted, no shadow.
        case locked
    }

    let digit: Character?
    let style: Style

    /// Dash/gap lengths along `DashedRoundedRect`'s path (radius 11, starting
    /// after the top-left corner, clockwise), measured from the mockup's empty
    /// box: about 8pt dashes on the top and bottom, 10–12pt on the sides and
    /// corner arcs. Odd length like the Home button's: SwiftUI repeats the
    /// array, and the tail entry closes the path's seam.
    private static let emptyDash: [CGFloat] = [
        4.0, 7.0, 8.0, 7.0, 8.53, 8.21, 10.37, 10.33, 11.67, 10.33, 10.37, 8.21,
        8.54, 7.0, 8.0, 7.0, 8.53, 8.22, 10.38, 10.33, 11.67, 10.33, 10.37, 8.2, 4.55,
    ]

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .circular)

        ZStack {
            content
        }
        .frame(width: 56, height: 70)
        .background(fill, in: shape)
        .overlay { border(in: shape) }
        .modifier(BoxShadow(isVisible: hasShadow, shape: shape))
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if style == .active {
            // 1.5pt left of center, where the mockup draws it.
            Rectangle()
                .fill(Color.black)
                .frame(width: 3, height: 30)
                .offset(x: -1.5)
        } else if let digit {
            Text(String(digit))
                .font(.codeDigit)
                .foregroundStyle(digitColor)
                .offset(y: Self.digitOffsetY)
        }
    }

    /// A centered Almarai digit sits 1pt above the mockup's. Two of the
    /// mockup's own 8/7 boxes sit 3pt lower than the rest, so this matches the
    /// majority (every box of the error and room-full states but those two).
    private static let digitOffsetY: CGFloat = 1

    // MARK: - Style

    private var fill: Color {
        switch style {
        case .filled, .empty: .white
        case .active: .brandYellow
        case .error: .tintRed
        case .locked: .lockedFill
        }
    }

    private var digitColor: Color {
        switch style {
        case .error: .inkText
        case .locked: .lockedText
        default: .black
        }
    }

    private var hasShadow: Bool {
        switch style {
        case .filled, .active, .error: true
        case .empty, .locked: false
        }
    }

    @ViewBuilder
    private func border(in shape: RoundedRectangle) -> some View {
        switch style {
        case .filled, .active: shape.strokeBorder(Color.inkStroke, lineWidth: 3)
        case .error: shape.strokeBorder(Color.brandRed, lineWidth: 3)
        case .locked: shape.strokeBorder(Color.lockedStroke, lineWidth: 3)
        case .empty:
            // Dashed line's center sits 2pt in from the edge so its 4pt
            // width fills the outer 4pt, like an inside stroke.
            DashedRoundedRect(cornerRadius: 11)
                .stroke(Color.black.opacity(0.35), style: StrokeStyle(lineWidth: 4, lineCap: .butt, dash: Self.emptyDash))
                .padding(2)
        }
    }
}

/// Applies the boxes' (3,3) hard shadow only to the styles that have one.
private struct BoxShadow: ViewModifier {
    let isVisible: Bool
    let shape: RoundedRectangle

    func body(content: Content) -> some View {
        if isVisible {
            content.hardShadow(in: shape, offset: CGSize(width: 3, height: 3))
        } else {
            content
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        CodeDigitBox(digit: "8", style: .filled)
        CodeDigitBox(digit: nil, style: .active)
        CodeDigitBox(digit: nil, style: .empty)
        CodeDigitBox(digit: "2", style: .error)
        CodeDigitBox(digit: "4", style: .locked)
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .leftToRight)
}
