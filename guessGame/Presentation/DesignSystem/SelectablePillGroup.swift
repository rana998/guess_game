import SwiftUI

/// A titled row of `SelectablePillButton`s bound to one selection, shared by
/// Create Room's player-count and round-duration choosers. The title sits above
/// the first (physical-right) pill.
struct SelectablePillGroup<Value: Hashable & CustomStringConvertible>: View {
    let title: String
    let caption: String
    let values: [Value]
    @Binding var selection: Value
    let pillWidth: CGFloat
    let pillSpacing: CGFloat
    let identifierPrefix: String

    var body: some View {
        // `.leading` is the physical right under the app's forced RTL layout.
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.labelGroup)
                .foregroundStyle(Color.inkText)
                .frame(height: 17)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: pillSpacing) {
                ForEach(values, id: \.self) { value in
                    SelectablePillButton(
                        value: value.description,
                        caption: caption,
                        isSelected: value == selection,
                        width: pillWidth
                    ) {
                        selection = value
                    }
                    .accessibilityIdentifier("\(identifierPrefix).\(value.description)")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selection = 60

    SelectablePillGroup(
        title: Strings.CreateRoom.durationTitle,
        caption: Strings.CreateRoom.durationCaption,
        values: [30, 60, 90],
        selection: $selection,
        pillWidth: 108,
        pillSpacing: 11,
        identifierPrefix: "preview.duration"
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
