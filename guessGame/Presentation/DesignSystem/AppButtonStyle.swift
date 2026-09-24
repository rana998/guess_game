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

extension HardShadowButtonStyle {
    /// The same style at another size, for buttons that share a treatment but
    /// not a footprint (Enter Name's 377×56 green button is `appPrimaryHeavy`).
    func sized(width: CGFloat, height: CGFloat) -> HardShadowButtonStyle {
        var style = self
        style.width = width
        style.height = height
        return style
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

    /// Join Room's keypad key: 86×52pt, 13pt circular radius, 4pt ink border, (4,4)
    /// shadow, ExtraBold 22 label sitting 1pt above center per the mockup.
    /// `fill`/`textColor` carry the three key roles (digit, delete, confirm).
    static func appKey(fill: Color, textColor: Color) -> HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: fill,
            borderColor: .inkStroke,
            borderWidth: 4,
            cornerRadius: 13,
            width: 86,
            height: 52,
            shadowOffset: CGSize(width: 4, height: 4),
            shadowColor: .black,
            font: .inputText,
            textColor: textColor,
            cornerStyle: .circular,
            labelOffsetY: -1
        )
    }

    /// The room-full card's action buttons: 53pt tall, 13pt circular radius, 3pt
    /// ink border, (3,3) shadow, ExtraBold 20 label. Only the width and fill differ.
    static func appCardAction(fill: Color, width: CGFloat) -> HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: fill,
            borderColor: .inkStroke,
            borderWidth: 3,
            cornerRadius: 13,
            width: width,
            height: 53,
            shadowOffset: CGSize(width: 3, height: 3),
            shadowColor: .black,
            font: .titleScreen,
            textColor: .black,
            cornerStyle: .circular
        )
    }

    /// The waiting room's 44pt white header button (the participant's kebab):
    /// `appCardAction`'s 13pt radius, 3pt border and (3,3) shadow.
    static var appHeaderIcon: HardShadowButtonStyle {
        var style = appCardAction(fill: .white, width: 44)
        style.height = 44
        return style
    }

    /// The owner's "نسخ" chip beside the room code: 83×44, 20pt radius,
    /// ExtraBold 14 label. The text-and-burst label sits 1pt right of center.
    static var appCopyChip: HardShadowButtonStyle {
        var style = appCardAction(fill: .white, width: 83)
        style.height = 44
        style.cornerRadius = 20
        style.font = .labelSection
        style.labelOffsetX = 1
        return style
    }

    /// The waiting room's footer action (start game / ready toggle): 192×53,
    /// 16pt radius. Only the fill differs between roles and states.
    static func appLobbyAction(fill: Color) -> HardShadowButtonStyle {
        var style = appCardAction(fill: fill, width: 192)
        style.height = 53
        style.cornerRadius = 16
        return style
    }
}

extension ButtonStyle where Self == TertiaryDashedButtonStyle {
    /// How to Play: dashed 4pt round-capped center border, fixed 228×46pt, no shadow.
    static var appTertiaryDashed: TertiaryDashedButtonStyle { TertiaryDashedButtonStyle() }
}
