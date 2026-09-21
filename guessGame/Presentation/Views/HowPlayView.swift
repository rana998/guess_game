import SwiftUI

/// Static rules screen pushed from Home's "كيف تلعب؟" button and from Settings.
/// Five `InfoCard`s (three tall, two compact) and a black points bar under the
/// shared `ScreenHeader`.
///
/// Built to the landscape 852×393pt mockup. Surfaces that are white, yellow or
/// black in the mockup stay literal in Dark Mode (same precedent as
/// HomeSettingView), so their text uses literal colors rather than the tokens.
struct HowPlayView: View {
    @Environment(\.dismiss) private var dismiss

    private enum Metrics {
        static let tallCardWidth: CGFloat = 227
        static let tallRowSpacing: CGFloat = 8
        static let mainRowWidth = tallCardWidth * 3 + tallRowSpacing * 2
        static let compactRowSpacing: CGFloat = 6
        static let describerCardWidth: CGFloat = 349
        static let guessersCardWidth: CGFloat = 350
        static let rowSpacing: CGFloat = 14
        /// The bottom row runs 8pt past the top row and bar (to x=775, not 767),
        /// so the whole column is this wide.
        static let columnWidth = describerCardWidth + compactRowSpacing + guessersCardWidth
        /// Extra space on the physical right of the column: shifts it 3.5pt
        /// left of the screen's center, to x=70…775 on the 852pt canvas
        /// (70pt margin on the left, 77pt on the right).
        static let overhang: CGFloat = 7
        static let contentTop: CGFloat = 17
        /// The narrowest width that holds the column (705pt plus its 7pt
        /// overhang) with about 11pt to spare on each side. Narrower screens
        /// (iPhone SE class) scale the column down uniformly instead of
        /// clipping it; anything at least this wide is untouched. Measured on
        /// iPhone 16 landscape the content area is the full 852pt, so the
        /// scale is exactly 1 there.
        static let fitReferenceWidth: CGFloat = 734
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: Strings.HowPlay.title,
                backAccessibilityLabel: Strings.HowPlay.backAccessibilityLabel,
                horizontalInset: 41,
                titleSpacing: 10,
                onBack: { dismiss() }
            )

            GeometryReader { geometry in
                content
                    .frame(width: geometry.size.width)
                    .scaleEffect(min(1, geometry.size.width / Metrics.fitReferenceWidth), anchor: .top)
            }
            .padding(.top, Metrics.contentTop)
        }
        .frame(maxWidth: .infinity)
        .background(Color.paper.ignoresSafeArea())
        // Card and line heights are pixel-measured and fixed, so larger
        // Dynamic Type sizes would clip them.
        .dynamicTypeSize(.large)
        .navigationBarHidden(true)
    }

    // MARK: - Content

    // The HStacks list cards in reading order: the first child is the
    // physical right under the app's forced RTL layout. `.trailing` alignment
    // is the physical left, where the narrower rows end.
    private var content: some View {
        VStack(alignment: .trailing, spacing: Metrics.rowSpacing) {
            HStack(spacing: Metrics.tallRowSpacing) {
                InfoCard(
                    title: Strings.HowPlay.setIdeaTitle,
                    description: Strings.HowPlay.setIdeaDescription,
                    icon: .question,
                    variant: .tall,
                    width: Metrics.tallCardWidth,
                    style: .lime
                )
                InfoCard(
                    title: Strings.HowPlay.addDetailsTitle,
                    description: Strings.HowPlay.addDetailsDescription,
                    icon: .cube,
                    variant: .tall,
                    width: Metrics.tallCardWidth,
                    style: .white
                )
                InfoCard(
                    title: Strings.HowPlay.subIdeaTitle,
                    description: Strings.HowPlay.subIdeaDescription,
                    icon: .exclaim,
                    variant: .tall,
                    width: Metrics.tallCardWidth,
                    style: .red
                )
            }
            .frame(width: Metrics.mainRowWidth, alignment: .leading)

            HStack(spacing: Metrics.compactRowSpacing) {
                InfoCard(
                    title: Strings.HowPlay.describerTitle,
                    description: Strings.HowPlay.describerDescription,
                    variant: .compact,
                    width: Metrics.describerCardWidth,
                    style: .yellow
                )
                InfoCard(
                    title: Strings.HowPlay.guessersTitle,
                    description: Strings.HowPlay.guessersDescription,
                    variant: .compact,
                    width: Metrics.guessersCardWidth,
                    style: .whiteBlack
                )
            }

            pointsBar
        }
        .frame(width: Metrics.columnWidth, alignment: .trailing)
        .padding(.leading, Metrics.overhang)
        .frame(maxWidth: .infinity)
    }

    private var pointsBar: some View {
        HStack(spacing: 9) {
            Text(Strings.HowPlay.pointsTitle)
                .font(.labelSection)
                .foregroundStyle(Color.white)
            Text(Strings.HowPlay.pointsDescription)
                .font(.bodySmall)
                .foregroundStyle(Color.white.opacity(0.75))
                // The mockup's 11pt runs sit 1pt above the bar's center.
                .offset(y: -1)
            Spacer(minLength: 0)
            Text(Strings.HowPlay.rounds)
                .font(.bodySmall)
                .foregroundStyle(Color.white.opacity(0.75))
                .offset(y: -1)
        }
        .padding(.horizontal, 17)
        .frame(width: Metrics.mainRowWidth, height: 40)
        .background(Color.black, in: RoundedRectangle(cornerRadius: 13, style: .circular))
        .accessibilityElement(children: .combine)
    }
}

#Preview("iPhone 16 — Landscape", traits: .landscapeLeft) {
    NavigationStack {
        HowPlayView()
    }
    .environment(\.layoutDirection, .rightToLeft)
}
