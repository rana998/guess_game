import SwiftUI

/// Shared layout for a pushed screen that has no real content yet — used by
/// JoinRoomView until its real UI and logic are built in a later phase.
struct PlaceholderDestinationView: View {
    let title: String
    let comingSoonText: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.titleScreen)
                .foregroundStyle(Color.inkText)
            Text(comingSoonText)
                .font(.bodyRegular)
                .foregroundStyle(Color.inkText.opacity(0.55))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paper)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
