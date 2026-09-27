import SwiftUI

/// The round screens' white header band and its 3pt black rule, holding the
/// screen's controls.
struct GameTopBar<Content: View>: View {
    let height: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .frame(height: height)
                .background(Color.white)
            Color.black
                .frame(height: 3)
        }
    }
}
