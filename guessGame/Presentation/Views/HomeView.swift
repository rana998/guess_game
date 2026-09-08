import SwiftUI

/// The app's real entry point. Static landscape composition: the "تخمين" wordmark
/// lockup on the leading (physically right, under RTL) side, the three action
/// buttons and player-count caption on the trailing side — matching Home.png.
///
/// Landscape-only by design: Home.png is pixel-exact to iPhone 16's landscape point
/// size and DESIGN_SYSTEM.md defines landscape-specific safe-area rules, so this
/// screen set doesn't attempt a portrait layout.
struct HomeView: View {
    @State private var path: [HomeDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.paper.ignoresSafeArea()

                content
                    // System safe area already accounts for sensor-housing clearance
                    // based on actual rotation (LandscapeLeft vs LandscapeRight); this
                    // adds DESIGN_SYSTEM.md's extra 16pt content margin on top of it.
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .createRoom: CreateRoomView()
                case .joinRoom: JoinRoomView()
                case .howToPlay: HowPlayView()
                }
            }
        }
    }

    private var content: some View {
        HStack(spacing: 32) {
            StarburstLogo()
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 16) {
                Button(Strings.Home.createRoom) { path.append(.createRoom) }
                    .buttonStyle(.appPrimary)

                Button(Strings.Home.joinRoom) { path.append(.joinRoom) }
                    .buttonStyle(.appSecondary)

                HStack(spacing: 12) {
                    Button(Strings.Home.howToPlay) { path.append(.howToPlay) }
                        .buttonStyle(.appTertiaryDashed)
                    ellipsisBadge
                }

                Text(Strings.Home.playerCountCaption)
                    .font(.bodyMeta)
                    .foregroundStyle(Color.inkText.opacity(0.55))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var ellipsisBadge: some View {
        Image(systemName: "ellipsis")
            .font(.labelSection)
            .foregroundStyle(Color.inkStroke)
            .frame(width: 44, height: 44)
            .background(Color.paper, in: Circle())
            .overlay(Circle().strokeBorder(Color.inkStroke, lineWidth: 2))
    }
}
