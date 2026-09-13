import SwiftUI

/// The "تخمين" wordmark lockup: the real starburst PNG asset (yellow burst,
/// black outline, baked-in soft glow), a template-tinted copy of the same
/// asset as its hard-offset shadow, the outlined red wordmark, and the black
/// subtitle ribbon — matching Home.png's composition. Sizes proportionally:
/// every child is positioned as a fraction of this view's own frame, which is
/// locked to the asset's real 3:2 pixel ratio (1536x1024) so those fractions
/// never drift out of alignment with the artwork, regardless of what size
/// HomeView gives this view on a given device/orientation.
///
/// The asset's baked-in soft glow means the shadow layer below doesn't read
/// as a perfectly crisp DESIGN_SYSTEM.md "hard, never blurred" shadow — that
/// mismatch is inherent to using the real exported artwork rather than a
/// hand-drawn shape, and is accepted rather than papered over.
struct StarburstLogo: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Hard-offset shadow: a template-tinted copy of the real
                // artwork (its own alpha channel as the mask), not a
                // hand-drawn shape. Offset is DESIGN_SYSTEM.md's fixed
                // "primary elements" (6,4) token, same as AppButtonStyle.
                Image("starburst")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.inkStroke)
                    .offset(x: 6, y: 4)

                // Full-color artwork, as-is — its own outline/glow is used
                // directly, no extra .stroke() overlay.
                Image("starburst")
                    .resizable()
                    .scaledToFit()

                ComicOutlineText(
                    text: Strings.Home.title,
                    font: .displayLogo,
                    fillColor: .brandRed,
                    strokeColor: .black,
                    strokeWidth: 3
                )
                .lineLimit(1)
                .frame(width: 221, height: 78)

                subtitleRibbon
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .frame(maxWidth: geo.size.width * 0.80)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.87)
            }
        }
        // Locks this view to the asset's real 3:2 ratio (1536x1024) so the
        // fractional placements above always align with the rendered image,
        // no matter what box HomeView offers this view.
        .aspectRatio(3.0 / 2.0, contentMode: .fit)
    }

    private var subtitleRibbon: some View {
        Text(Strings.Home.subtitle)
            .font(.labelSection)
            .foregroundStyle(Color.paper)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.inkStroke, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
