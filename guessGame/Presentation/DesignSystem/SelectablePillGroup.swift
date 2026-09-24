import SwiftUI

/// A row of `SelectablePillButton`s bound to one selection, shared by Create
/// Room's player-count and round-duration choosers and the waiting room's
/// duration pills. The optional title sits above the first (physical-right) pill.
struct SelectablePillGroup<Value: Hashable & CustomStringConvertible>: View {
    let title: String?
    let caption: String?
    let values: [Value]
    @Binding var selection: Value
    let pillWidth: CGFloat
    let pillSpacing: CGFloat
    let identifierPrefix: String
    var size: SelectablePillButton.Size = .regular

    init(
        title: String?,
        caption: String?,
        values: [Value],
        selection: Binding<Value>,
        pillWidth: CGFloat,
        pillSpacing: CGFloat,
        identifierPrefix: String,
        size: SelectablePillButton.Size = .regular
    ) {
        self.title = title
        self.caption = caption
        self.values = values
        _selection = selection
        self.pillWidth = pillWidth
        self.pillSpacing = pillSpacing
        self.identifierPrefix = identifierPrefix
        self.size = size
    }

    var body: some View {
        // `.leading` is the physical right under the app's forced RTL layout.
        VStack(alignment: .leading, spacing: 9) {
            if let title {
                Text(title)
                    .font(.labelGroup)
                    .foregroundStyle(Color.inkText)
                    .frame(height: 17)
                    .accessibilityAddTraits(.isHeader)
            }

            HStack(spacing: pillSpacing) {
                ForEach(values, id: \.self) { value in
                    SelectablePillButton(
                        value: value.description,
                        caption: caption,
                        isSelected: value == selection,
                        width: pillWidth,
                        size: size
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

    VStack(spacing: 24) {
        SelectablePillGroup(
            title: Strings.CreateRoom.durationTitle,
            caption: Strings.CreateRoom.durationCaption,
            values: Room.roundSecondsOptions,
            selection: $selection,
            pillWidth: 108,
            pillSpacing: 11,
            identifierPrefix: "preview.duration"
        )
        SelectablePillGroup(
            title: nil,
            caption: nil,
            values: Room.roundSecondsOptions,
            selection: $selection,
            pillWidth: 49,
            pillSpacing: 16,
            identifierPrefix: "preview.compactDuration",
            size: .compact
        )
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
