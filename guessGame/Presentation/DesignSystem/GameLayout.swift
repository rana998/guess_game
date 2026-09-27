import CoreGraphics

/// The round screens are drawn on their mockups' 852×393 canvas and shrink
/// uniformly on screens too narrow for their content.
enum GameLayout {
    static let canvasSize = CGSize(width: 852, height: 393)

    static func fitScale(forWidth width: CGFloat, referenceWidth: CGFloat) -> CGFloat {
        width >= referenceWidth ? 1 : width / referenceWidth
    }
}
