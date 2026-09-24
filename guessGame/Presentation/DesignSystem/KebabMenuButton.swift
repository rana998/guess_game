import SwiftUI

/// The participant's 44pt "more" button in the waiting-room header. Opens a
/// menu whose one action leaves the room.
struct KebabMenuButton: View {
    let accessibilityLabel: String
    let leaveTitle: String
    let onLeave: () -> Void

    var body: some View {
        Menu {
            Button(leaveTitle, role: .destructive, action: onLeave)
        } label: {
            // The button style lays its label out left to right, so this
            // offset is physical: the mockup's dots sit 0.5pt left and low.
            EllipsisDots()
                .offset(x: -0.5, y: 0.5)
        }
        .menuStyle(.button)
        .buttonStyle(.appHeaderIcon)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("waitingRoom.more")
    }
}

#if DEBUG
#Preview {
    KebabMenuButton(accessibilityLabel: Strings.WaitingRoom.moreAccessibilityLabel, leaveTitle: Strings.WaitingRoom.leaveRoom, onLeave: {})
        .padding(24)
        .background(Color.white)
        .environment(\.layoutDirection, .rightToLeft)
}
#endif
