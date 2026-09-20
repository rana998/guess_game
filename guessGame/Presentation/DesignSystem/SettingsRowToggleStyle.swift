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
    // The mockup is a native 51×31 switch stretched to 64×28, which leaves a
    // wide pill knob outlined in the track color rather than a round one.
    private static let knobSize = CGSize(width: 40, height: 26)
    private static let knobInset: CGFloat = 1

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
            // Leading is the right edge under RTL, where the label sits; the
            // switch side gets the smaller margin. Both are measured from the
            // card's outer edge in the spec (switch x=201 in a card at x=187).
            .padding(.leading, 26)
            .padding(.trailing, 14)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? Strings.HomeSetting.on : Strings.HomeSetting.off)
    }

    private func track(isOn: Bool) -> some View {
        let trackColor = isOn ? Self.onColor : Self.offColor
        let travel = Self.trackSize.width - Self.knobSize.width - Self.knobInset * 2

        return ZStack(alignment: .leading) {
            Capsule().fill(trackColor)
            Capsule()
                .fill(Color.white)
                .overlay(Capsule().strokeBorder(trackColor, lineWidth: 1))
                .frame(width: Self.knobSize.width, height: Self.knobSize.height)
                .offset(x: Self.knobInset + (isOn ? travel : 0))
        }
        .frame(width: Self.trackSize.width, height: Self.trackSize.height)
        .animation(.easeOut(duration: 0.15), value: isOn)
        // Raw `.offset(x:)` mirrors under the app-wide RTL environment; pin the
        // switch to LTR so the knob always rests right when on, left when off.
        .environment(\.layoutDirection, .leftToRight)
    }
}
