import SwiftUI

/// A pill-shaped message with a white "!" badge, drawn in the comic style: 3pt
/// black border and a hard (4,4) shadow. Its width follows its text; the icon
/// sits at the reading start (the physical right under the app's RTL layout).
struct MessageBanner: View {
    let text: String
    var fill: Color = .brandRed

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12.5, style: .circular)

        HStack(spacing: 8) {
            ExclamationBadge()
            Text(text)
                .font(.messageBanner)
                .foregroundStyle(Color.white)
                // Almarai's line box centers the ink 1.5pt below the mockup's.
                .offset(y: -1.5)
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(fill, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 3))
        .hardShadow(in: shape, offset: CGSize(width: 4, height: 4))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

/// The banner's 24pt white circle with a 2pt black ring and an "!" drawn from
/// two rectangles: the mockup's glyph is not an Almarai character.
private struct ExclamationBadge: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle().fill(Color.white)
            Circle().strokeBorder(Color.black, lineWidth: 2)
            Rectangle()
                .fill(Color.black)
                .frame(width: 1.75, height: 7.7)
                .offset(x: 11, y: 7)
            Rectangle()
                .fill(Color.black)
                .frame(width: 1.75, height: 2.05)
                .offset(x: 11, y: 15)
        }
        .frame(width: 24, height: 24)
        // Raw `.offset(x:)` mirrors under the app-wide RTL environment (same
        // caveat as HardShadowButtonStyle); the glyph's offsets are physical.
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    MessageBanner(text: Strings.JoinRoom.invalidCodeMessage)
        .padding(24)
        .background(Color.paper)
        .environment(\.layoutDirection, .rightToLeft)
}
