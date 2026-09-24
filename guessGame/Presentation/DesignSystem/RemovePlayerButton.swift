import SwiftUI

/// The owner's red "−" button on another player's waiting-room card. Draws
/// 39×39 and takes 39×39 of layout, but answers taps across 44×44.
struct RemovePlayerButton: View {
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 11, style: .circular)
        Button(action: action) {
            Rectangle()
                .fill(Color.brandRed)
                .frame(width: 15, height: 2)
                .frame(width: 39, height: 39)
                .background(Color.tintRed, in: shape)
                .overlay(shape.strokeBorder(Color.brandRed, lineWidth: 3))
                // HIG: a 44pt hit area around the 39pt visual. The negative padding
                // below keeps the layout footprint at the measured 39pt.
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .padding(-2.5)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Dims on press; the mockup gives this button no shadow to collapse into.
    struct PressStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

#if DEBUG
#Preview {
    RemovePlayerButton(accessibilityLabel: Strings.WaitingRoom.removeAccessibilityLabel(name: "سلمان"), action: {})
        .padding(24)
        .background(Color.white)
        .environment(\.layoutDirection, .rightToLeft)
}
#endif
