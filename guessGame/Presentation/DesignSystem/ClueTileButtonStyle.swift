import SwiftUI

/// A board tile as a button. Unlike `.plain`, it doesn't grey out a disabled
/// tile, so a tagged tile keeps its green or red tint; it only dims while pressed.
struct ClueTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == ClueTileButtonStyle {
    static var appClueTile: ClueTileButtonStyle { ClueTileButtonStyle() }
}
