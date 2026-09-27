#if DEBUG
import SwiftUI

/// Development only, while games live on one device: shows whose view is on
/// screen and switches to another player's, so every seat of a round can be
/// played by hand. Release builds show only the device's own player.
struct ViewerSwitcher: View {
    let viewer: AvatarModel
    let choices: [ViewerChoice]
    let onChoose: (String) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 8) {
            Button {
                isExpanded.toggle()
            } label: {
                AvatarBadge(initial: viewer.initial, color: viewer.color.color, size: .medium)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Strings.GameDebug.switcherLabel)
            .accessibilityValue(viewer.name)
            .accessibilityIdentifier("game.debug.viewerSwitcher")
            if isExpanded {
                choiceList
            }
        }
    }

    private var choiceList: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .circular)
        return VStack(spacing: 0) {
            ForEach(choices) { choice in
                Button {
                    isExpanded = false
                    onChoose(choice.id)
                } label: {
                    Text(choice.title)
                        .font(.labelSection)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("game.debug.viewer.\(choice.id)")
            }
        }
        .frame(width: 200)
        .background(Color.white, in: shape)
        .overlay(shape.strokeBorder(Color.black, lineWidth: 3))
    }
}
#endif
