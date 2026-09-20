import SwiftUI

/// Renders a whole settings row: the label on the leading edge and a 64×28pt
/// switch on the trailing edge. The entire row is the tap target, since the
/// switch alone is under the 44pt minimum in DESIGN_SYSTEM.md.
struct SettingsRowToggleStyle: ToggleStyle {
    // Literal values from the Figma spec (iOS system green / 30% system gray),
    // not brand tokens.
    private static let onColor = Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x59 / 255)
    private static let offColor = Color(red: 0x3C / 255, green: 0x3C / 255, blue: 0x43 / 255).opacity(0.3)

    private static let trackSize = CGSize(width: 64, height: 28)
    private static let knobInset: CGFloat = 2

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                    .font(.titleCard)
                    // The card is white in both appearances, so this must not
                    // use InkText, which inverts to off-white in Dark Mode.
                    .foregroundStyle(Color.black)
                Spacer()
                track(isOn: configuration.isOn)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? Strings.HomeSetting.on : Strings.HomeSetting.off)
    }

    private func track(isOn: Bool) -> some View {
        let knobSize = Self.trackSize.height - Self.knobInset * 2
        let travel = Self.trackSize.width - knobSize - Self.knobInset * 2

        return ZStack(alignment: .leading) {
            Capsule().fill(isOn ? Self.onColor : Self.offColor)
            Circle()
                .fill(Color.white)
                .frame(width: knobSize, height: knobSize)
                .offset(x: Self.knobInset + (isOn ? travel : 0))
        }
        .frame(width: Self.trackSize.width, height: Self.trackSize.height)
        .animation(.easeOut(duration: 0.15), value: isOn)
        // Raw `.offset(x:)` mirrors under the app-wide RTL environment; pin the
        // switch to LTR so the knob always rests right when on, left when off.
        .environment(\.layoutDirection, .leftToRight)
    }
}
