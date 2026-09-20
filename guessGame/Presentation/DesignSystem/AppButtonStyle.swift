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

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        configuration.label
            .font(.labelSection)
            .foregroundStyle(Color.inkStroke)
            .frame(width: 228, height: 46)
            .background(Color.paper, in: shape)
            // Plain `.stroke` (not `.strokeBorder`) centers the dashed line on
            // the shape's edge, matching Figma's "stroke position: center"
            // setting for this element only.
            .overlay(
                shape.stroke(Color.black, style: StrokeStyle(lineWidth: 4, dash: [14, 7]))
            )
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == HardShadowButtonStyle {
    /// إنشاء غرفة (Create Room), primary CTA. Exact Figma spec: 288x60pt, 14pt
    /// radius, BrandLime fill, 4pt black inside stroke, hard (6,4) black shadow.
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
            textColor: .inkStroke
        )
    }

    /// انضم إلى غرفة (Join Room), secondary CTA. Same 288x60pt/14pt-radius/
    /// 4pt-stroke/(6,4)-shadow treatment as the primary button per Figma spec —
    /// only the fill differs (white, not BrandLime).
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
            textColor: .inkStroke
        )
    }
}

extension ButtonStyle where Self == TertiaryDashedButtonStyle {
    /// How to Play: dashed 4pt center border, fixed 228×46pt, no shadow.
    static var appTertiaryDashed: TertiaryDashedButtonStyle { TertiaryDashedButtonStyle() }
}
