import SwiftUI

/// The "who is in the room" card: a title, a list of `PlayerRow`s each followed
/// by a dashed rule, and a footer line. White with a 4pt ink border and hard
/// shadow.
///
/// The card is a fixed 270×208pt like the mockup, so it never resizes as
/// players join. Its list is a 123.75pt viewport — exactly three rows — that
/// scrolls when the room has more; title and footer stay pinned. Six rows
/// would not fit the 393pt-tall screen, which is why the list scrolls.
struct PlayersCard: View {
    let title: String
    let rows: [PlayerRow.Model]
    let footer: String
    /// Ids are `<prefix>.players`, `<prefix>.player.<index>` and `<prefix>.count`.
    let identifierPrefix: String

    private static let contentSize = CGSize(width: 262, height: 200)
    private static let borderWidth: CGFloat = 4
    private static let titleZoneHeight: CGFloat = 38
    private static let rowPitch = PlayerRow.height + 3
    private static let listHeight = 3 * rowPitch
    /// Text sits 9.5pt in from the interior's reading-start edge.
    private static let textInset: CGFloat = 9.5

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .circular)

        VStack(spacing: 0) {
            Text(title)
                .font(.labelSection)
                .foregroundStyle(Color.black)
                .padding(.top, 9.25)
                .padding(.leading, Self.textInset)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: Self.titleZoneHeight, alignment: .top)
                .accessibilityAddTraits(.isHeader)

            list

            Text(footer)
                .font(.bodySmall)
                .foregroundStyle(Color.black.opacity(0.45))
                .padding(.top, 11.2)
                .padding(.leading, Self.textInset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .accessibilityIdentifier("\(identifierPrefix).count")
        }
        .frame(width: Self.contentSize.width, height: Self.contentSize.height)
        .padding(Self.borderWidth)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.inkStroke, lineWidth: Self.borderWidth))
        .hardShadow(in: shape, offset: CGSize(width: 4, height: 4))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("\(identifierPrefix).players")
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    PlayerRow(model: row)
                        .accessibilityIdentifier("\(identifierPrefix).player.\(index)")
                    DashedRule()
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicatorsFlash(onAppear: true)
        .frame(height: Self.listHeight)
    }
}

#Preview {
    PlayersCard(
        title: Strings.EnterName.playersTitle,
        rows: [
            .init(player: Player(id: "1", name: "نهى", color: .green, isOwner: true), ownerCaption: Strings.EnterName.ownerCaption),
            .init(player: Player(id: "2", name: "سلمان", color: .teal, isOwner: false), ownerCaption: Strings.EnterName.ownerCaption),
            .init(player: Player(id: "3", name: "لمى", color: .gold, isOwner: false), ownerCaption: Strings.EnterName.ownerCaption),
        ],
        footer: Strings.EnterName.playersCount(count: 3, capacity: 6),
        identifierPrefix: "preview"
    )
    .padding(24)
    .background(Color.paper)
    .environment(\.layoutDirection, .rightToLeft)
}
