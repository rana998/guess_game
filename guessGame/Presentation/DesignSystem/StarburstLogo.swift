import SwiftUI

/// A 12-point comic starburst, built as a native Shape (not an image asset) so it
/// recolors correctly for Dark Mode and mirrors correctly under RTL.
struct StarburstShape: Shape {
    var points: Int = 12
    var innerRadiusRatio: CGFloat = 0.72

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio
        let vertexCount = points * 2

        var path = Path()
        for i in 0..<vertexCount {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            i == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

/// The "تخمين" wordmark lockup: yellow starburst with a hard offset shadow, the
/// outlined red wordmark centered on it, and the black subtitle ribbon overlapping
/// its bottom edge — matching Home.png's composition.
struct StarburstLogo: View {
    var body: some View {
        ZStack {
            StarburstShape()
                .fill(Color.inkStroke)
                .offset(x: 6, y: 4)

            StarburstShape()
                .fill(Color.brandYellow)
                .overlay(StarburstShape().stroke(Color.inkStroke, lineWidth: 4))

            ComicOutlineText(
                text: Strings.Home.title,
                font: .displayLogo,
                fillColor: .brandRed,
                strokeColor: .inkStroke,
                strokeWidth: 4
            )
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .padding(40)
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .bottom) {
            subtitleRibbon
                .offset(y: 14)
        }
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
