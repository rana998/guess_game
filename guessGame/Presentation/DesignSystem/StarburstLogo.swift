import SwiftUI

/// The "تخمين" wordmark lockup: a single final exported PNG (starburst,
/// wordmark, and subtitle ribbon all baked in by design) — placed as-is,
/// with no SwiftUI-drawn shapes, shadows, or text composited on top.
/// Locked to the asset's real 407:271 pixel ratio so it never distorts,
/// regardless of what size HomeView gives this view on a given
/// device/orientation.
struct StarburstLogo: View {
    var body: some View {
        Image("starburst")
            .resizable()
            .scaledToFit()
            .aspectRatio(407.0 / 271.0, contentMode: .fit)
    }
}
