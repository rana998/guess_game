import SwiftUI

/// The app's real entry point. Adaptively arranges the "تخمين" wordmark
/// lockup and the action-button column as an HStack in landscape or a
/// VStack in portrait, picked live from measured width vs. height — no
/// fixed device breakpoints — so it works across all supported iPhone
/// sizes and both orientations.
struct HomeView: View {
    @State private var path: [HomeDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.paper.ignoresSafeArea()

                GeometryReader { geometry in
                    content(isWide: geometry.size.width > geometry.size.height, size: geometry.size)
                }
                // Padding stays outside the GeometryReader so geometry.size
                // already reflects the post-padding content area.
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

    @ViewBuilder
    private func content(isWide: Bool, size: CGSize) -> some View {
        if isWide {
            HStack(spacing: 32) {
                StarburstLogo()
                    .frame(maxWidth: .infinity)
                buttonColumn
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    StarburstLogo()
                        .frame(maxWidth: size.width * 0.78)
                    buttonColumn
                }
                // Centers when content fits (the common case); scrolls only
                // if enlarged Dynamic Type pushes past available height.
                .frame(minHeight: size.height)
            }
        }
    }

    private var buttonColumn: some View {
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

    private var ellipsisBadge: some View {
        Image(systemName: "ellipsis")
            .font(.labelSection)
            .foregroundStyle(Color.inkStroke)
            .frame(width: 46, height: 46)
            .background(Color.paper, in: Circle())
            .overlay(Circle().strokeBorder(Color.inkStroke, lineWidth: 2))
    }
}

#Preview("iPhone SE — Portrait") {
    HomeView()
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
}

#Preview("iPhone 16 — Portrait") {
    HomeView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 16"))
}

#Preview("iPhone 16 — Landscape", traits: .landscapeLeft) {
    HomeView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 16"))
}
