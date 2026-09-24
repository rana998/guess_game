import Foundation
import Observation

/// The waiting room's state and rules for either role: who is in the room and
/// ready, the owner's round length, removing players, and when the game starts.
/// Holds no UI types (the pasteboard comes in as a closure), so every rule is
/// testable without a view.
@Observable
final class WaitingRoomViewModel {
    private(set) var room: Room
    let role: RoomRole
    let currentPlayerId: String
    private(set) var phase: WaitingRoomPhase = .waiting
    private(set) var isShowingCopyConfirmation = false
    /// Bumped on every copy, so a timer from an earlier tap can't hide the
    /// confirmation of a later one.
    private(set) var copyConfirmationToken = 0

    @ObservationIgnored private let copyToPasteboard: (String) -> Void
    /// Called once, with the room as it stands, when the game starts. No
    /// gameplay screen exists yet, so HomeView passes a no-op.
    @ObservationIgnored private let onStartGame: (Room) -> Void
    @ObservationIgnored private let onLeave: () -> Void

    init(
        session: WaitingRoomSession,
        copyToPasteboard: @escaping (String) -> Void,
        onStartGame: @escaping (Room) -> Void = { _ in },
        onLeave: @escaping () -> Void = {}
    ) {
        room = session.room
        role = session.role
        currentPlayerId = session.currentPlayerId
        self.copyToPasteboard = copyToPasteboard
        self.onStartGame = onStartGame
        self.onLeave = onLeave
    }

    // MARK: - Derived

    var roomCode: String { room.code }

    var isOwner: Bool { role == .owner }

    var isStarting: Bool { phase == .starting }

    var currentPlayer: Player? { room.players.first { $0.id == currentPlayerId } }

    var isCurrentPlayerReady: Bool { currentPlayer?.isReady ?? false }

    var readyCount: Int { room.players.filter(\.isReady).count }

    var readyCountText: String { Strings.WaitingRoom.readyCount(ready: readyCount, total: room.players.count) }

    var hasEnoughPlayers: Bool { room.players.count >= Room.minimumPlayers }

    /// The owner may start with enough players even if some aren't ready yet.
    var canStart: Bool { isOwner && phase == .waiting && hasEnoughPlayers }

    var startButtonTitle: String { isStarting ? Strings.WaitingRoom.startingGame : Strings.WaitingRoom.startGame }

    var readyToggleTitle: String { isCurrentPlayerReady ? Strings.WaitingRoom.cancelReady : Strings.WaitingRoom.markReady }

    var participantCaption: String { isStarting ? Strings.WaitingRoom.startingGame : Strings.WaitingRoom.autoStartCaption }

    var roundSeconds: Int { room.roundSeconds }

    /// The players in order, then an empty seat for each free place up to capacity.
    var slots: [WaitingRoomSlot] {
        let players = room.players.map {
            WaitingRoomSlot.player(PlayerWaitingCard.Model(player: $0, currentPlayerId: currentPlayerId, viewerRole: role))
        }
        let empties = (room.players.count..<max(room.players.count, room.capacity)).map { WaitingRoomSlot.empty(index: $0) }
        return players + empties
    }

    // MARK: - Intents

    /// The owner is always ready and has no toggle.
    func toggleReady() {
        guard !isOwner, phase == .waiting,
              let index = room.players.firstIndex(where: { $0.id == currentPlayerId }) else { return }
        room.players[index].isReady.toggle()
        autoStartIfEveryoneReady()
    }

    /// Only the owner removes players, and never themselves.
    func removePlayer(id: String) {
        guard isOwner, phase == .waiting, id != currentPlayerId,
              let index = room.players.firstIndex(where: { $0.id == id }),
              !room.players[index].isOwner else { return }
        room.players.remove(at: index)
        autoStartIfEveryoneReady()
    }

    func copyRoomCode() {
        copyToPasteboard(room.code)
        copyConfirmationToken += 1
        isShowingCopyConfirmation = true
    }

    func clearCopyConfirmation(token: Int) {
        guard token == copyConfirmationToken else { return }
        isShowingCopyConfirmation = false
    }

    func setRoundSeconds(_ seconds: Int) {
        guard isOwner, phase == .waiting, Room.roundSecondsOptions.contains(seconds) else { return }
        room.roundSeconds = seconds
    }

    func startGame() {
        guard canStart else { return }
        beginStart()
    }

    func leaveRoom() {
        onLeave()
    }

    // MARK: - Starting

    /// Runs after every change a player makes, on either role's device, so
    /// the game starts by itself once enough players are all ready. Not at
    /// init: opening a room that is already all ready doesn't start it.
    private func autoStartIfEveryoneReady() {
        guard phase == .waiting, hasEnoughPlayers, room.players.allSatisfy(\.isReady) else { return }
        beginStart()
    }

    /// The single start path, for the owner's button and the auto-start alike,
    /// so the game can only start once.
    private func beginStart() {
        phase = .starting
        onStartGame(room)
    }
}
