import SwiftUI

/// The yellow capsule showing which room you are in: a small caption
/// ("غرفة") and the room code. Hugs its content; the code's proportional
/// digits make the width vary slightly, so callers anchor its left edge.
struct RoomCodePill: View {
    let caption: String
    let code: String

    var body: some View {
        // The caption is first, so it sits at the reading start (physical right).
        HStack(spacing: 7.5) {
            Text(caption)
                .font(.messageBanner)
                .foregroundStyle(Color.black)
            Text(code)
                .font(.titleCard)
                .foregroundStyle(Color.black)
        }
        // The 3pt border plus 8.75 of breathing room.
        .padding(.horizontal, 11.75)
        .frame(height: 40)
        .background(Color.brandYellow, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.black, lineWidth: 3))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(caption) \(code)")
    }
}

#Preview {
    RoomCodePill(caption: Strings.EnterName.roomCaption, code: "8701")
        .padding(24)
        .background(Color.white)
        .environment(\.layoutDirection, .rightToLeft)
}
