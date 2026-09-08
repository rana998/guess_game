import SwiftUI

/// Comic-style button treatment shared by DESIGN_SYSTEM.md's button tokens: a solid
/// ink-stroke border, a hard (never blurred) offset shadow rendered as a second flat
/// shape behind the button rather than a blurred system shadow, and a press state
/// that drops the shadow to 0 while the button shifts into its place.
struct HardShadowButtonStyle: ButtonStyle {
    var fill: Color
    var borderWidth: CGFloat
    var cornerRadius: CGFloat
    var height: CGFloat
    var shadowOffset: CGSize
    var font: Font
    var horizontalPadding: CGFloat
    var fullWidth: Bool

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let isPressed = configuration.isPressed

        ZStack {
            if !isPressed {
                shape
                    .fill(Color.inkStroke)
                    .offset(x: shadowOffset.width, y: shadowOffset.height)
            }

            configuration.label
                .font(font)
                .foregroundStyle(Color.inkStroke)
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: height)
                .background(fill, in: shape)
                .overlay(shape.strokeBorder(Color.inkStroke, lineWidth: borderWidth))
                .offset(x: isPressed ? shadowOffset.width : 0, y: isPressed ? shadowOffset.height : 0)
        }
        .animation(.easeOut(duration: 0.08), value: isPressed)
    }
}

/// The How to Play button's dashed, content-hugging, de-emphasized treatment —
/// no shadow, matching its secondary status in the mockup.
struct TertiaryDashedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        configuration.label
            .font(.labelSection)
            .foregroundStyle(Color.inkStroke)
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color.paper, in: shape)
            .overlay(
                shape.strokeBorder(Color.inkStroke, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
            )
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == HardShadowButtonStyle {
    /// Create Room: filled BrandLime, 3pt border, 50pt CTA height, (6,4) shadow.
    static var appPrimary: HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: .brandLime,
            borderWidth: 3,
            cornerRadius: 12,
            height: 50,
            shadowOffset: CGSize(width: 6, height: 4),
            font: .displayCTA,
            horizontalPadding: 24,
            fullWidth: true
        )
    }

    /// Join Room: filled Paper, 3pt border, 50pt CTA height, (4,4) shadow.
    static var appSecondary: HardShadowButtonStyle {
        HardShadowButtonStyle(
            fill: .paper,
            borderWidth: 3,
            cornerRadius: 12,
            height: 50,
            shadowOffset: CGSize(width: 4, height: 4),
            font: .displayCTA,
            horizontalPadding: 24,
            fullWidth: true
        )
    }
}

extension ButtonStyle where Self == TertiaryDashedButtonStyle {
    /// How to Play: dashed 2pt border, 44pt height, content-hugging, no shadow.
    static var appTertiaryDashed: TertiaryDashedButtonStyle { TertiaryDashedButtonStyle() }
}
