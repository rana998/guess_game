import SwiftUI

@main
struct guessGameApp: App {
    init() {
        // SwiftUI's environment override alone doesn't reliably mirror UIKit-backed
        // chrome (e.g. NavigationStack's back-chevron placement); force it here too.
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
