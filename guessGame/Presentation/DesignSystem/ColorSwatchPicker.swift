import SwiftUI

/// A row of 44pt color circles; the selected one carries a red ring drawn
/// inside its edge. Generic over the option type so callers select by identity
/// rather than by comparing `Color`s, which is unreliable for asset colors.
///
/// Options are listed in reading order: the first is the physical right under
/// the app's forced RTL layout.
struct ColorSwatchPicker<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let groupLabel: String
    let identifierPrefix: String
    let color: (Option) -> Color
    let optionLabel: (Option) -> String

    private static var diameter: CGFloat { 44 }

    var body: some View {
        HStack(spacing: 8.6) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection

                Button {
                    selection = option
                } label: {
                    Circle()
                        .fill(color(option))
                        .frame(width: Self.diameter, height: Self.diameter)
                        .overlay {
                            if isSelected {
                                Circle().strokeBorder(Color.brandRed, lineWidth: 3)
                            }
                        }
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(optionLabel(option))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityIdentifier("\(identifierPrefix).\(String(describing: option))")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(groupLabel)
    }
}

#Preview {
    @Previewable @State var selection = AvatarColor.green

    ColorSwatchPicker(
        options: AvatarColor.allCases,
        selection: $selection,
        groupLabel: Strings.CreateRoom.avatarColorLabel,
        identifierPrefix: "preview.swatch",
        color: \.color,
        optionLabel: \.accessibilityLabel
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
