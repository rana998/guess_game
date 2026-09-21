import SwiftUI

/// A white card with a thick red border and a hard (9,9) shadow: a count badge
/// and headline, a dashed divider, a message and two actions. Used for the
/// room-full result, but nothing in it is specific to joining a room.
///
/// Fixed 380×174pt per the mockup. The primary action (green) is the first
/// button, at the reading start (physical right under RTL).
struct AlertCard: View {
    let badge: String
    let title: String
    let subtitle: String
    let message: String
    let primaryTitle: String
    let onPrimary: () -> Void
    let secondaryTitle: String
    let onSecondary: () -> Void
    let identifier: String
    let primaryIdentifier: String
    let secondaryIdentifier: String

    private static let contentWidth: CGFloat = 368
    private static let contentHeight: CGFloat = 162
    private static let borderWidth: CGFloat = 6

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .circular)

        VStack(spacing: 0) {
            header
                .padding(.top, 11)
            DashedRule()
                .padding(.top, 14)
            Text(message)
                .font(.bodyStrong)
                .foregroundStyle(Color.black.opacity(0.65))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 16)
                .padding(.top, 2)
            actions
                .padding(.top, 6)
        }
        .frame(width: Self.contentWidth, height: Self.contentHeight, alignment: .top)
        .padding(Self.borderWidth)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.brandRed, lineWidth: Self.borderWidth))
        .hardShadow(in: shape, offset: CGSize(width: 9, height: 9))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
    }

    // MARK: - Parts

    // The badge is first, so it sits at the reading start.
    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            countBadge
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.titleScreen)
                    .foregroundStyle(Color.black)
                    .frame(height: 22)
                Text(subtitle)
                    .font(.bodyStrong)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .frame(height: 14)
            }
            .padding(.top, 10)
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
        }
        // Pinned to the badge's height so the block's taller text column
        // (which overhangs it) doesn't push the divider down.
        .frame(height: 44, alignment: .top)
        .padding(.leading, 19)
    }

    private var countBadge: some View {
        Text(badge)
            .font(.badgeMono)
            .foregroundStyle(Color.white)
            .offset(y: -1)
            .frame(width: 44, height: 44)
            .background(Color.brandRed, in: Circle())
            .overlay(Circle().strokeBorder(Color.black, lineWidth: 3))
            // The message already carries the number.
            .accessibilityHidden(true)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Button(primaryTitle, action: onPrimary)
                .buttonStyle(.appCardAction(fill: .brandLime, width: 192))
                .accessibilityIdentifier(primaryIdentifier)
            Button(secondaryTitle, action: onSecondary)
                .buttonStyle(.appCardAction(fill: .white, width: 134))
                .accessibilityIdentifier(secondaryIdentifier)
        }
        .padding(.horizontal, 16)
    }
}

/// The card's 3pt-tall dashed rule: 6pt dashes with 5.93pt gaps, the phase
/// measured from the mockup so the dashes line up with its first one.
private struct DashedRule: View {
    var body: some View {
        Line()
            .stroke(Color.black.opacity(0.25), style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash: [6, 5.93], dashPhase: 4))
            .frame(height: 3)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    AlertCard(
        badge: Strings.JoinRoom.roomFullBadge(capacity: 6),
        title: Strings.JoinRoom.roomFullTitle,
        subtitle: Strings.JoinRoom.roomFullSubtitle,
        message: Strings.JoinRoom.roomFullMessage(capacity: 6),
        primaryTitle: Strings.JoinRoom.retryButton,
        onPrimary: {},
        secondaryTitle: Strings.JoinRoom.homeButton,
        onSecondary: {},
        identifier: "preview.card",
        primaryIdentifier: "preview.card.primary",
        secondaryIdentifier: "preview.card.secondary"
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
