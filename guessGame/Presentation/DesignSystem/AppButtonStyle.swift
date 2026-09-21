import SwiftUI

/// Comic-style button treatment shared by DESIGN_SYSTEM.md's button tokens: a solid
/// ink-stroke border, a hard (never blurred) offset shadow rendered as a second flat
/// shape behind the button rather than a blurred system shadow, and a press state
/// that drops the shadow to 0 while the button shifts into its place. Fixed
/// width/height per Figma spec (not content-hugging) — the Home CTAs are a
/// fixed 288x60pt regardless of label length.
struct HardShadowButtonStyle: ButtonStyle {
    var fill: Color
    var borderColor: Color
    var borderWidth: CGFloat
    var cornerRadius: CGFloat
    var width: CGFloat
    var height: CGFloat
    var shadowOffset: CGSize
    var shadowColor: Color
    var font: Font
    var textColor: Color
    // Defaulted so existing call sites (HomeSettingView, RoundedChevronButton)
    // keep their continuous corners and centered labels untouched.
    var cornerStyle: RoundedCornerStyle = .continuous
    /// Vertical nudge for labels the mockup places off their natural center.
    var labelOffsetY: CGFloat = 0
    /// Physical (not RTL-mirrored) horizontal nudge: this style pins its subtree to LTR.
    var labelOffsetX: CGFloat = 0

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: cornerStyle)
        let isPressed = configuration.isPressed

        ZStack {
            if !isPressed {
                shape
                    .fill(shadowColor)
                    .frame(width: width, height: height)
                    .offset(x: shadowOffset.width, y: shadowOffset.height)
            }

            configuration.label
                .font(font)
                .foregroundStyle(textColor)
                .offset(x: labelOffsetX, y: labelOffsetY)
                .frame(width: width, height: height)
                .background(fill, in: shape)
                // strokeBorder insets the line inside the shape's bounds,
                // matching Figma's "stroke position: inside" setting.
                .overlay(shape.strokeBorder(borderColor, lineWidth: borderWidth))
                .offset(x: isPressed ? shadowOffset.width : 0, y: isPressed ? shadowOffset.height : 0)
        }
        .animation(.easeOut(duration: 0.08), value: isPressed)
        // The app forces RTL globally for Arabic text flow (see guessGameApp),
        // but SwiftUI also mirrors raw `.offset(x:)` under that environment —
        // it silently flipped this hard shadow to bottom-LEFT instead of the
        // Figma-specified bottom-RIGHT. Pinning this subtree back to LTR
        // cancels that mirroring; it doesn't affect the label's Arabic glyph
        // shaping, which comes from the string's own script, not this flag.
        .environment(\.layoutDirection, .leftToRight)
    }
}

/// The How to Play button's dashed, de-emphasized treatment — no shadow,
/// matching its secondary status in the mockup. Fixed 228×46pt per Figma spec
/// (not content-hugging).
struct TertiaryDashedButtonStyle: ButtonStyle {
    /// Dash/gap lengths along `DashedRoundedRect`'s path, measured from the
    /// mockup. Every dash is 11pt (15pt visible, since round caps add 4pt),
    /// but the gaps are not uniform: Figma restarts the pattern on each
    /// straight edge, so the top and bottom carry 10 dashes each while each
    /// side carries only 2, just 2.8pt apart. A uniform pattern can't
    /// reproduce that. Sums to the 522.25pt perimeter (24 dashes: the first
    /// 6pt and last 5pt entries join across the path's closing seam).
    private static let dashPattern: [CGFloat] = [
        6.0, 11.3, 11, 10.7, 11, 10.9, 11, 10.8, 11, 10.6, 11, 10.8, 11, 10.9, 11, 10.7, 11, 11.3,
        11, 12.6, 11, 5.93, 11, 12.6,
        11, 11.3, 11, 10.7, 11, 10.9, 11, 10.8, 11, 10.6, 11, 10.8, 11, 10.9, 11, 10.7, 11, 11.3,
        11, 12.6, 11, 5.92, 11, 12.6, 5.0,
    ]

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.ctaTertiary)
            .foregroundStyle(Color.inkStroke)
            // The mockup's label ink sits 7pt left of the shape's center; 14pt
            // of physical-right padding moves a centered label by half of that.
            .padding(.trailing, 14)
            .frame(width: 228, height: 46)
            .background(Color.paper, in: RoundedRectangle(cornerRadius: 15, style: .circular))
            // Plain `.stroke` centers the dashed line on the shape's edge
            // (Figma "stroke position: center"), so it extends 2pt past the
            // 228×46 frame.
            .overlay(
                DashedRoundedRect(cornerRadius: 15)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: Self.dashPattern))
            )
            .opacity(configuration.isPressed ? 0.6 : 1)
            // Same RTL caveat as HardShadowButtonStyle: keeps the physical
            // padding above on the right.
            .environment(\.layoutDirection, .leftToRight)
    }
}

/// A rounded rectangle whose path starts at the top edge just after the
/// top-left corner and runs clockwise. SwiftUI's own RoundedRectangle doesn't
/// document its start point, and the dash phase measured from the mockup
/// depends on it.
private struct DashedRoundedRect: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let r = cornerRadius
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY + r), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX - r, y: rect.maxY), radius: r)
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY - r), radius: r)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.minX + r, y: rect.minY), radius: r)
        path.closeSubpath()
        return path
    }
}

extension ButtonStyle where Self == HardShadowButtonStyle {
    /// إنشاء غرفة (Create Room), primary CTA. Exact Figma spec: 288x60pt, 14pt
    /// circular radius, BrandLime fill, 4pt black inside stroke, hard (6,4) black
    /// shadow, pure-black Bold 30 label.
    static var appPrimary: HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: .brandLime,
            borderColor: .black,
            borderWidth: 4,
            cornerRadius: 14,
            width: 288,
            height: 60,
            shadowOffset: CGSize(width: 6, height: 4),
            shadowColor: .black,
            font: .displayCTA,
            textColor: .black,
            cornerStyle: .circular
        )
    }

    /// Create Room's submit button: `appPrimary`'s box, border and shadow, but the
    /// mockup sets its label in ExtraBold and 3pt right of center.
    static var appPrimaryHeavy: HardShadowButtonStyle {
        var style = appPrimary
        style.font = .displayCTAHeavy
        style.labelOffsetX = 3
        return style
    }

    /// انضم إلى غرفة (Join Room), secondary CTA. Same 288x60pt/14pt-radius/
    /// 4pt-stroke/(6,4)-shadow treatment as the primary button per Figma spec —
    /// only the fill differs (white, not BrandLime), plus the mockup's 2pt upward
    /// label offset.
    static var appSecondary: HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: .white,
            borderColor: .black,
            borderWidth: 4,
            cornerRadius: 14,
            width: 288,
            height: 60,
            shadowOffset: CGSize(width: 6, height: 4),
            shadowColor: .black,
            font: .displayCTA,
            textColor: .black,
            cornerStyle: .circular,
            labelOffsetY: -2
        )
    }
}

extension ButtonStyle where Self == TertiaryDashedButtonStyle {
    /// How to Play: dashed 4pt round-capped center border, fixed 228×46pt, no shadow.
    static var appTertiaryDashed: TertiaryDashedButtonStyle { TertiaryDashedButtonStyle() }
}
