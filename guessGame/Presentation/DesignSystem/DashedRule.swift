import SwiftUI

/// A 3pt-tall dashed rule: 6pt dashes with 5.93pt gaps, the phase measured from
/// the mockups so the first dash starts 8pt in. Shared by the room-full card's
/// divider and the Enter Name player list's row dividers.
struct DashedRule: View {
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
    DashedRule()
        .frame(width: 262)
        .padding(24)
        .background(Color.white)
}
