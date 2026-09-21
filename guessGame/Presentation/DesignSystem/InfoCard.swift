import SwiftUI

/// A bordered, tinted card carrying an optional badge icon, a title and a
/// description — the building block of the How to Play screen. `tall` cards
/// (icon on top, hard shadow, two-line descriptions) and `compact` cards
/// (title over a single line, flat) are two measured layouts of one component;
/// everything that differs between cards of a variant lives in `Style`/`Icon`.
///
/// Content is pinned to the physical right under the app's forced RTL layout
/// (`.leading` is the right edge there), matching the mockup.
struct InfoCard: View {
    enum Variant {
        case tall
        case compact

        var height: CGFloat { self == .tall ? 136 : 53 }
        var cornerRadius: CGFloat { self == .tall ? 14 : 13 }
        var horizontalInset: CGFloat { self == .tall ? 12 : 20 }
        var topInset: CGFloat { self == .tall ? 12 : 10 }
    }

    /// A badge from the asset catalog. The PNGs carry large transparent
    /// margins, so `size` is the frame that makes the visible ink land where
    /// the mockup shows it, and `leadingInset` its extra distance from the
    /// card's content edge (each icon sits at a slightly different offset).
    struct Icon {
        let assetName: String
        let size: CGSize
        let leadingInset: CGFloat
    }

    struct Style {
        let fill: Color
        let border: Color
        let borderWidth: CGFloat
        let text: Color
    }

    let title: String
    /// Lines are separated by "\n" and never re-wrapped, so they break exactly
    /// where the mockup does.
    let description: String
    var icon: Icon?
    let variant: Variant
    let width: CGFloat
    let style: Style

    private static let iconSlotHeight: CGFloat = 31
    /// Hard shadow of the tall variant; the compact variant is flat.
    private static let shadowOffset: CGFloat = 5
    /// Measured baseline-to-baseline pitch of the 11pt description lines.
    private static let descriptionLineHeight: CGFloat = 12

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: variant.cornerRadius, style: .circular)

        ZStack {
            if variant == .tall {
                shape
                    .fill(Color.black)
                    .frame(width: width, height: variant.height)
                    .offset(x: Self.shadowOffset, y: Self.shadowOffset)
                    // Raw `.offset(x:)` mirrors under the app-wide RTL environment
                    // (same caveat as HardShadowButtonStyle) — pin only this
                    // decorative shadow layer back to LTR so it stays bottom-right.
                    .environment(\.layoutDirection, .leftToRight)
            }

            content
                .padding(.horizontal, variant.horizontalInset)
                .padding(.top, variant.topInset)
                .frame(width: width, height: variant.height, alignment: .topLeading)
                .background(style.fill, in: shape)
                .overlay(shape.strokeBorder(style.border, lineWidth: style.borderWidth))
        }
        .frame(width: width, height: variant.height)
        // Lines are separate views to pin their pitch, so read the card as one
        // sentence instead of a stop per line.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(description.replacingOccurrences(of: "\n", with: " "))")
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch variant {
            case .tall:
                iconSlot
                Text(title)
                    .font(.titleCard)
                    .foregroundStyle(style.text)
                    .frame(height: 18)
                    .padding(.top, 3.5)
                descriptionLines
                    .padding(.top, 6.5)
            case .compact:
                Text(title)
                    .font(.labelSection)
                    .foregroundStyle(style.text)
                    .frame(height: 16)
                descriptionLines
                    .padding(.top, 7)
            }
        }
    }

    private var iconSlot: some View {
        Group {
            if let icon {
                Image(icon.assetName)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: icon.size.width, height: icon.size.height)
                    .padding(.leading, icon.leadingInset)
                    .accessibilityHidden(true)
            }
        }
        .frame(height: Self.iconSlotHeight)
    }

    private var descriptionLines: some View {
        let lines = description.components(separatedBy: "\n")

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.bodySmall)
                    .foregroundStyle(style.text)
                    .frame(height: Self.descriptionLineHeight, alignment: .leading)
            }
        }
        .fixedSize()
    }
}

extension InfoCard.Icon {
    static let question = InfoCard.Icon(assetName: "badge-question", size: CGSize(width: 17.33, height: 26), leadingInset: 4.87)
    static let cube = InfoCard.Icon(assetName: "badge-cube", size: CGSize(width: 29.25, height: 19.5), leadingInset: 1.88)
    static let exclaim = InfoCard.Icon(assetName: "badge-exclaim", size: CGSize(width: 17, height: 25.5), leadingInset: 2)
}

extension InfoCard.Style {
    // Cards on adaptive tints take the adaptive `inkText`; cards that are
    // literally white or yellow in the mockup stay literal black in both
    // appearances (same precedent as HomeSettingView's white surfaces).
    static let lime = InfoCard.Style(fill: .tintLime, border: .brandLimeDeep, borderWidth: 4, text: .inkText)
    static let red = InfoCard.Style(fill: .tintRed, border: .brandRed, borderWidth: 3, text: .inkText)
    static let white = InfoCard.Style(fill: .white, border: .inkStroke, borderWidth: 4, text: .black)
    static let yellow = InfoCard.Style(fill: .brandYellow, border: .black, borderWidth: 3, text: .black)
    static let whiteBlack = InfoCard.Style(fill: .white, border: .black, borderWidth: 3, text: .black)
}

#Preview {
    VStack(alignment: .trailing, spacing: 16) {
        HStack(spacing: 8) {
            InfoCard(title: Strings.HowPlay.setIdeaTitle, description: Strings.HowPlay.setIdeaDescription, icon: .question, variant: .tall, width: 227, style: .lime)
            InfoCard(title: Strings.HowPlay.addDetailsTitle, description: Strings.HowPlay.addDetailsDescription, icon: .cube, variant: .tall, width: 227, style: .white)
            InfoCard(title: Strings.HowPlay.subIdeaTitle, description: Strings.HowPlay.subIdeaDescription, icon: .exclaim, variant: .tall, width: 227, style: .red)
        }
        HStack(spacing: 6) {
            InfoCard(title: Strings.HowPlay.describerTitle, description: Strings.HowPlay.describerDescription, variant: .compact, width: 349, style: .yellow)
            InfoCard(title: Strings.HowPlay.guessersTitle, description: Strings.HowPlay.guessersDescription, variant: .compact, width: 350, style: .whiteBlack)
        }
    }
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
