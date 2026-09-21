import SwiftUI

/// The 52pt circular player preview next to Create Room's name field: the
/// chosen swatch color with the first letter of the entered name.
struct AvatarBadge: View {
    let initial: String
    let color: Color

    var body: some View {
        Text(initial)
            .font(.inputText)
            .foregroundStyle(Color.black)
            // Leading is the physical right under RTL, so this moves the glyph
            // 1.5pt left of center, where the mockup places it.
            .padding(.leading, 3)
            .offset(y: -1)
            .frame(width: 52, height: 52)
            .background(color, in: Circle())
            .overlay(Circle().strokeBorder(Color.black, lineWidth: 4))
            .hardShadow(in: Circle(), offset: CGSize(width: 3, height: 3))
            .accessibilityHidden(true)
    }

    /// First letter of the trimmed name; falls back to the placeholder's so the
    /// badge never sits empty before anything is typed. Takes a whole
    /// `Character` (a grapheme), so a diacritic stays attached to its letter.
    static func initial(from name: String, placeholder: String) -> String {
        let typed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = typed.isEmpty ? placeholder.trimmingCharacters(in: .whitespacesAndNewlines) : typed
        return source.first.map { String($0).uppercased() } ?? ""
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarBadge(initial: "ن", color: .brandLime)
        AvatarBadge(initial: "S", color: .avatarBlue)
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
