import SwiftUI

/// Carries a scrolled content's top edge, in its scroll view's coordinate
/// space, up to the view that draws a custom scroll indicator.
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
