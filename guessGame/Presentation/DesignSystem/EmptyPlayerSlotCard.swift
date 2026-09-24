import SwiftUI

/// An open seat in the waiting-room grid, up to the room's capacity: a dashed
/// 242×89 outline reading "بانتظار لاعب". Unfilled, so the Paper band shows
/// through and its text uses `inkText`.
struct EmptyPlayerSlotCard: View {
    var body: some View {
        Text(Strings.WaitingRoom.emptySlot)
            .font(.bodySmall)
            .foregroundStyle(Color.inkText.opacity(0.55))
            .frame(width: 242, height: 89)
            // Padding stands in for strokeBorder: DashedRoundedRect isn't an
            // InsettableShape, and the 3pt line must stay inside the card frame.
            .overlay(
                DashedRoundedRect(cornerRadius: 14)
                    .stroke(Color.inkText.opacity(0.3), style: StrokeStyle(lineWidth: 3, dash: [6, 5]))
                    .padding(1.5)
            )
            .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    EmptyPlayerSlotCard()
        .padding(24)
        .background(Color.paper)
        .environment(\.layoutDirection, .rightToLeft)
}
#endif
