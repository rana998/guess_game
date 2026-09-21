import SwiftUI

/// The player-name text field shared by Create Room and Enter Name: a white
/// box with a thick ink border and hard shadow, black ExtraBold text and a gray
/// hint that disappears once something is typed. The caret is `brandRed`.
///
/// Fixed 52pt tall and as wide as its container gives it. Text starts at the
/// reading start (physical right under RTL), `textInset` in from the edge.
struct NameField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let label: String
    let placeholder: String
    let identifier: String
    /// Distance from the box's reading-start edge to the text, per mockup:
    /// 18pt on Create Room, 24pt on Enter Name.
    var textInset: CGFloat = 18

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .circular)

        TextField(
            label,
            text: $text,
            prompt: Text(placeholder).foregroundStyle(Color.black.opacity(0.5))
        )
        .font(.inputText)
        .foregroundStyle(Color.black)
        .tint(.brandRed)
        .multilineTextAlignment(.leading)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.done)
        .onSubmit { isFocused.wrappedValue = false }
        .focused(isFocused)
        // Leading is the physical right under RTL, where the text starts.
        .padding(.leading, textInset)
        // UITextField centers its line box a little low against the mockup's
        // ink (measured 0.7pt); this lifts the text by half the padding.
        .padding(.bottom, 1.5)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.inkStroke, lineWidth: 4))
        .hardShadow(in: shape, offset: CGSize(width: 4, height: 4))
        // The whole box focuses the field, not just the text's own frame.
        .contentShape(Rectangle())
        .onTapGesture { isFocused.wrappedValue = true }
        .accessibilityIdentifier(identifier)
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @FocusState var isFocused: Bool

    NameField(
        text: $name,
        isFocused: $isFocused,
        label: Strings.CreateRoom.nameFieldLabel,
        placeholder: Strings.CreateRoom.namePlaceholder,
        identifier: "preview.nameField"
    )
    .frame(width: 333)
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
