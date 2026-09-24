import SwiftUI

/// A player's round avatar: the chosen color with the first letter of their
/// name. `large` is the 52pt live preview next to a name field (Create Room,
/// Enter Name); `medium` is the 36pt waiting-room card avatar; `small` is the
/// 30pt marker in a player-list row.
struct AvatarBadge: View {
    enum Size {
        case large
        case medium
        case small

        var diameter: CGFloat {
            switch self {
            case .large: 52
            case .medium: 36
            case .small: 30
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .large: 4
            case .medium: 3
            case .small: 2
            }
        }

        /// Only the large avatar casts the hard shadow; the others are flat.
        var shadowOffset: CGFloat? {
            switch self {
            case .large: 3
            case .medium, .small: nil
            }
        }

        var font: Font {
            switch self {
            case .large: .inputText
            case .medium: .labelSection
            case .small: .avatarInitialSmall
            }
        }

        /// Leading is the physical right under RTL, so these move the glyph
        /// left of center, where the mockups place it. The waiting-room
        /// mockup centers its glyph, so `medium` needs no nudge.
        var glyphLeadingInset: CGFloat {
            switch self {
            case .large: 3
            case .medium: 0
            case .small: 1.5
            }
        }

        var glyphLift: CGFloat {
            switch self {
            case .large: 1
            case .medium: 0
            case .small: 0.5
            }
        }
    }

    let initial: String
    let color: Color
    var size: Size = .large
    /// Decorative badges are hidden from VoiceOver (the row or field next to
    /// them already says the name). The live preview passes `false` and labels
    /// itself.
    var isDecorative = true

    var body: some View {
        let badge = Text(initial)
            .font(size.font)
            .foregroundStyle(Color.black)
            .padding(.leading, size.glyphLeadingInset)
            .offset(y: -size.glyphLift)
            .frame(width: size.diameter, height: size.diameter)
            .background(color, in: Circle())
            .overlay(Circle().strokeBorder(Color.black, lineWidth: size.borderWidth))

        Group {
            if let shadow = size.shadowOffset {
                badge.hardShadow(in: Circle(), offset: CGSize(width: shadow, height: shadow))
            } else {
                badge
            }
        }
        .accessibilityHidden(isDecorative)
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
        AvatarBadge(initial: "ر", color: .avatarPink, size: .medium)
        AvatarBadge(initial: "س", color: .avatarTeal, size: .small)
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
