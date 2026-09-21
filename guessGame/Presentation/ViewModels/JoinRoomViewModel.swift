import Foundation
import Observation

/// Entry rules and result state for Join Room: which digits are typed, what a
/// submit resolves to, and how each box should look. Holds no UI types, so the
/// rules are testable without a view.
@Observable
final class JoinRoomViewModel {
    /// Maps a complete code to what the screen should show. The eventual join
    /// use case plugs in here; `.idle` means the code was accepted.
    typealias Resolver = (String) -> JoinRoomState

    static let codeLength = 4

    /// No room can exist until the join use case does, so every code is
    /// invalid for now — which also keeps the invalid-code UI reachable.
    static let noRoomsYet: Resolver = { _ in .invalidCode }

    /// Changed only through the intents below, so it is always at most
    /// `codeLength` ASCII digits.
    private(set) var code: String
    private(set) var state: JoinRoomState

    @ObservationIgnored private let resolve: Resolver

    /// `code` and `state` let previews and tests start anywhere; the code is
    /// sanitized so they can't build one the keypad couldn't.
    init(code: String = "", state: JoinRoomState = .idle, resolve: @escaping Resolver = JoinRoomViewModel.noRoomsYet) {
        self.code = String(code.filter { $0.isASCII && $0.isNumber }.prefix(Self.codeLength))
        self.state = state
        self.resolve = resolve
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

    /// An incomplete code can't match a room, so it counts as invalid.
    func confirm() {
        if case .roomFull = state { return }
        state = code.count < Self.codeLength ? .invalidCode : resolve(code)
    }

    func retry() {
        code = ""
        state = .idle
    }
}
