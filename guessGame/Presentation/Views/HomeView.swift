import SwiftUI

/// The app's real entry point. Arranges the "تخمين" wordmark lockup and the
/// action-button column as a fixed-size landscape composition (matching the
/// 852×393pt Home.png mockup) or a proportional portrait VStack, picked live
/// from measured width vs. height — no fixed device breakpoints.
struct HomeView: View {
    @State private var path: [HomeDestination] = []
    private let joinResolver: JoinRoomViewModel.Resolver

    /// `joinResolver` is the seam for the future join use case; until it
    /// exists, every code is rejected (see `JoinRoomViewModel.noRoomsYet`).
    init(joinResolver: @escaping JoinRoomViewModel.Resolver = JoinRoomViewModel.noRoomsYet) {
        self.joinResolver = joinResolver
    }

    /// Measurements taken from Home.png; the landscape composition is laid out
    /// in these points rather than proportionally.
    private enum Landscape {
        static let logoSize = CGSize(width: 407, height: 271)
        /// The starburst PNG carries 35pt of transparent margin on each side,
        /// so the group is centered by its visible ink, not its frame.
        static let logoTransparentMargin: CGFloat = 35
        static let columnWidth: CGFloat = 288
        static let gap: CGFloat = 18
        static let columnTop: CGFloat = 27
        static let minimumMargin: CGFloat = 16
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.paper.ignoresSafeArea()

                // Landscape is laid out against the physical screen, which is
                // what the mockup is defined on, so this layer ignores the
                // safe area. (Reading insets from an ignoring GeometryReader
                // returns zero, so portrait can't share this layer.)
                GeometryReader { geometry in
                    if geometry.size.width > geometry.size.height {
                        landscape(size: geometry.size)
                    }
                }
                .ignoresSafeArea()

                // Portrait stays inside the safe area with a 16/24pt margin.
                // Padding stays outside the GeometryReader so geometry.size
                // already reflects the post-padding content area.
                GeometryReader { geometry in
                    if geometry.size.width <= geometry.size.height {
                        portrait(size: geometry.size)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .createRoom: CreateRoomView()
                case .joinRoom:
                    JoinRoomView(viewModel: JoinRoomViewModel(
                        resolve: joinResolver,
                        onJoined: { path.append(.enterName($0)) }
                    ))
                case .howToPlay: HowPlayView()
                case .homeSetting: HomeSettingView()
                case .enterName(let room): EnterNameView(viewModel: EnterNameViewModel(room: room))
                }
            }
        }
    }

    private func landscape(size: CGSize) -> some View {
        // Only the logo shrinks on narrow landscape screens (iPhone SE class);
        // the button column keeps its fixed size so tap targets stay HIG-sized.
        // 1 for any width from 780pt up, i.e. every current notched iPhone.
        let scale = min(1, max(0.5, (size.width - 2 * Landscape.minimumMargin - Landscape.columnWidth - Landscape.gap)
            / (Landscape.logoSize.width + Landscape.logoTransparentMargin)))

        return HStack(alignment: .top, spacing: Landscape.gap) {
            StarburstLogo()
                .frame(width: Landscape.logoSize.width * scale, height: Landscape.logoSize.height * scale)
            buttonColumn
                .padding(.top, Landscape.columnTop * scale)
        }
        // Trailing is the physical left under the app's forced RTL layout.
        .padding(.trailing, Landscape.logoTransparentMargin * scale)
        .frame(width: size.width, height: size.height)
    }

    private func portrait(size: CGSize) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                StarburstLogo()
                    .frame(maxWidth: size.width * 0.78)
                buttonColumn
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // Centers when content fits (the common case); scrolls only
            // if enlarged Dynamic Type pushes past available height.
            .frame(minHeight: size.height)
        }
    }

    private var buttonColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(Strings.Home.createRoom) { path.append(.createRoom) }
                .buttonStyle(.appPrimary)

            Button(Strings.Home.joinRoom) { path.append(.joinRoom) }
                .buttonStyle(.appSecondary)

            HStack(spacing: 14) {
                Button(Strings.Home.howToPlay) { path.append(.howToPlay) }
                    .buttonStyle(.appTertiaryDashed)
                ellipsisBadge
            }

            Text(Strings.Home.playerCountCaption)
                .font(.bodyMeta)
                // Figma specifies pure #000000 at 55% opacity here, not the
                // InkText token (which lightens in Dark Mode for contrast) —
                // this caption stays literally black per spec in both appearances.
                .foregroundStyle(Color.black.opacity(0.55))
                .multilineTextAlignment(.center)
                // Centered under the dashed button (228pt wide, the row's
                // leading item). Height is left to the text's own intrinsic
                // size rather than a tight metrics box, which would clip
                // Arabic descenders.
                .frame(width: 228, alignment: .center)
        }
    }

    private var ellipsisBadge: some View {
        // Rounded square (not a circle) per Figma: 46x46pt, 14pt circular
        // radius, #FFFFFF fill, 4pt #0A0A0A inside stroke, no shadow.
        let shape = RoundedRectangle(cornerRadius: 14, style: .circular)
        return Button { path.append(.homeSetting) } label: {
            // Drawn as circles: the mockup's dots (5pt, 11pt pitch) are much
            // larger than SF Symbols' "ellipsis" glyph at any nearby size.
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Color.black).frame(width: 5, height: 5)
                }
            }
            .offset(y: 1.5)
            .frame(width: 46, height: 46)
            .background(Color.white, in: shape)
            .overlay(shape.strokeBorder(Color.inkStroke, lineWidth: 4))
        }
        // .plain keeps the exact custom look above — the default button style
        // would otherwise tint/alter it on press.
        .buttonStyle(.plain)
        .accessibilityLabel(Strings.Home.settingsAccessibilityLabel)
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
