import SwiftUI
import UIKit
import XCTest

/// Renders a screen into a PNG through a real window, for comparing against
/// the mockups by hand. `ImageRenderer` can't draw `Menu` or `TextField` (it
/// paints the red "unsupported" placeholder), so this hosts the view in a
/// `UIWindow` and snapshots it with `drawHierarchy` instead.
@MainActor
enum SnapshotRenderer {
    /// Where snapshots go. Only set when the run asks for them
    /// (`TEST_RUNNER_SNAPSHOT_DIR` reaches the test process as `SNAPSHOT_DIR`),
    /// so a normal test run skips the snapshot tests.
    static func outputDirectory() throws -> URL {
        guard let path = ProcessInfo.processInfo.environment["SNAPSHOT_DIR"], !path.isEmpty else {
            throw XCTSkip("Set TEST_RUNNER_SNAPSHOT_DIR to render snapshots")
        }
        let url = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// The view at 1x in the mockups' 852×393 landscape canvas, light, RTL,
    /// with no safe area, so 1 pixel is 1 point of the mockup.
    static func render<V: View>(_ view: V, size: CGSize = CGSize(width: 852, height: 393)) throws -> Data {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { connectedScene in connectedScene as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = .light

        let hostingController = UIHostingController(rootView: view
            .environment(\.layoutDirection, .rightToLeft)
            .environment(\.colorScheme, .light))
        hostingController.safeAreaRegions = []

        window.frame = CGRect(origin: .zero, size: size)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.frame = window.bounds
        hostingController.view.layoutIfNeeded()
        // Lets fonts, tasks and the first layout pass settle before drawing.
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(bounds: hostingController.view.bounds, format: format).image { _ in
            _ = hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        window.isHidden = true
        return try XCTUnwrap(image.pngData())
    }
}
