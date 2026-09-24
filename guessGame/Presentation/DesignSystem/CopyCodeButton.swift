import SwiftUI

/// The owner's "نسخ" chip beside the room code. While `isConfirmed` it reads
/// "تم النسخ" alone: the text plus the burst would overflow the 77pt interior.
struct CopyCodeButton: View {
    let isConfirmed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isConfirmed {
                Text(Strings.WaitingRoom.copied)
            } else {
                // The button style lays its label out left to right, so the
                // text sits on the physical left and the burst on the right.
                HStack(spacing: 5) {
                    Text(Strings.WaitingRoom.copy)
                    CopyBurstIcon()
                }
            }
        }
        .buttonStyle(.appCopyChip)
        .accessibilityLabel(Strings.WaitingRoom.copyAccessibilityLabel)
        .accessibilityValue(isConfirmed ? Strings.WaitingRoom.copied : "")
        .accessibilityIdentifier("waitingRoom.copy")
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        CopyCodeButton(isConfirmed: false, action: {})
        CopyCodeButton(isConfirmed: true, action: {})
    }
    .padding(24)
    .background(Color.white)
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
