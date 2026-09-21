import Foundation
import Observation

/// Entry rules and result state for Join Room: which digits are typed, what a
/// submit resolves to, and how each box should look. Holds no UI types, so the
/// rules are testable without a view.
@Observable
final class JoinRoomViewModel {
    /// Maps a complete code to what the join produced. The eventual join use
    /// case plugs in here.
    typealias Resolver = (String) -> JoinOutcome

    static let codeLength = 4

    /// No room can exist until the join use case does, so every code is
    /// invalid for now — which also keeps the invalid-code UI reachable.
    static let noRoomsYet: Resolver = { _ in .invalidCode }

    /// Changed only through the intents below, so it is always at most
    /// `codeLength` ASCII digits.
    private(set) var code: String
    private(set) var state: JoinRoomState

    @ObservationIgnored private let resolve: Resolver
    /// Called each time a code opens a room, so the owner of navigation can move
    /// on to the next screen.
    @ObservationIgnored private let onJoined: (Room) -> Void

    /// `code` and `state` let previews and tests start anywhere; the code is
    /// sanitized so they can't build one the keypad couldn't.
    init(
        code: String = "",
        state: JoinRoomState = .idle,
        resolve: @escaping Resolver = JoinRoomViewModel.noRoomsYet,
        onJoined: @escaping (Room) -> Void = { _ in }
    ) {
        self.code = String(code.filter { $0.isASCII && $0.isNumber }.prefix(Self.codeLength))
        self.state = state
        self.resolve = resolve
        self.onJoined = onJoined
    }

    // MARK: - Derived UI

    var isKeypadVisible: Bool {
        if case .roomFull = state { return false }
        return true
    }

    /// One entry per box, index 0 at the physical left (first digit typed).
    var slots: [CodeDigitRow.Slot] {
        let digits = Array(code)
        return (0..<Self.codeLength).map { index in
            let digit = index < digits.count ? digits[index] : nil
            let style: CodeDigitBox.Style
            switch state {
            case .idle:
                if index < digits.count {
                    style = .filled
                } else {
                    style = index == digits.count ? .active : .empty
                }
            case .invalidCode:
                style = .error
            case .roomFull:
                style = .locked
            }
            return CodeDigitRow.Slot(digit: digit, style: style)
        }
    }

    /// What VoiceOver should announce when the screen enters `state`.
    var announcement: String? {
        switch state {
        case .idle: nil
        case .invalidCode: Strings.JoinRoom.invalidCodeMessage
        case .roomFull: Strings.JoinRoom.roomFullTitle
        }
    }

    // MARK: - Intents

    /// Any edit leaves an error state first; a digit on a full code only does that.
    func appendDigit(_ digit: Int) {
        guard (0...9).contains(digit) else { return }
        state = .idle
        if code.count < Self.codeLength {
            code.append(String(digit))
        }
    }

    func deleteLast() {
        state = .idle
        if !code.isEmpty {
            code.removeLast()
        }
    }

    /// An incomplete code can't match a room, so it counts as invalid. A joined
    /// room leaves this screen in `.idle` and is handed to `onJoined`; the
    /// navigation that follows isn't a state of this screen.
    func confirm() {
        if case .roomFull = state { return }
        guard code.count == Self.codeLength else {
            state = .invalidCode
            return
        }
        switch resolve(code) {
        case .joined(let room):
            state = .idle
            onJoined(room)
        case .invalidCode:
            state = .invalidCode
        case .roomFull(let capacity):
            state = .roomFull(capacity: capacity)
        }
    }

    func retry() {
        code = ""
        state = .idle
    }
}
