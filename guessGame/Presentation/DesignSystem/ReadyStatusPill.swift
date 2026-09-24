import SwiftUI

/// A player's readiness on their waiting-room card: a green "جاهز" capsule with
/// a check, or a muted dashed "في الانتظار" capsule. Fixed 63×30. Hidden from
/// VoiceOver: the card's label already says the state.
struct ReadyStatusPill: View {
    enum Status {
        case ready
        case waiting
    }

    let status: Status

    var body: some View {
        Group {
            switch status {
            case .ready: ready
            case .waiting: waiting
            }
        }
        .frame(width: 63, height: 30)
        .accessibilityHidden(true)
    }

    // The text comes first, so under RTL it fills the right side and the check
    // sits at the physical left, 8pt in.
    private var ready: some View {
        HStack(spacing: 0) {
            Text(Strings.WaitingRoom.ready)
                .font(.messageBanner)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
            Checkmark()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 17, height: 13)
                .padding(.trailing, 8)
        }
        .frame(width: 63, height: 30)
        .background(Color.brandLime, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.inkStroke, lineWidth: 2))
    }

    private var waiting: some View {
        Text(Strings.WaitingRoom.waiting)
            .font(.bodySmall)
            .foregroundStyle(Color.lockedText)
            .frame(width: 63, height: 30)
            .background(Color.lockedFill, in: Capsule())
            // DashedRoundedRect isn't an InsettableShape, so padding stands in
            // for strokeBorder: the 2pt line stays inside the 63×30 frame.
            .overlay(
                DashedRoundedRect(cornerRadius: 14)
                    .stroke(Color.lockedText, style: StrokeStyle(lineWidth: 2, dash: [5.5, 5.5], dashPhase: 2.75))
                    .padding(1)
            )
    }

    /// The mockup's check, traced in a 17×13 box and scaled to the frame.
    struct Checkmark: Shape {
        func path(in rect: CGRect) -> Path {
            let sx = rect.width / 17
            let sy = rect.height / 13
            var path = Path()
            path.move(to: CGPoint(x: rect.minX + 1.5 * sx, y: rect.minY + 6.75 * sy))
            path.addLine(to: CGPoint(x: rect.minX + 6.25 * sx, y: rect.minY + 11.5 * sy))
            path.addLine(to: CGPoint(x: rect.minX + 15.5 * sx, y: rect.minY + 1.5 * sy))
            return path
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        ReadyStatusPill(status: .ready)
        ReadyStatusPill(status: .waiting)
    }
    .padding(24)
    .background(Color.white)
    .environment(\.layoutDirection, .rightToLeft)
}
#endif
