/// Stand-in for the server-issued room code until the create-room use case exists.
enum LocalRoomCode {
    /// The mockups' example code. Previews and test fixtures use it, so a real room must never get it.
    static let excludedCodes: Set<String> = ["8701"]

    /// Four ASCII digits, uniformly random over 0000–9999, redrawn while excluded.
    /// `String(format:)` isn't localized, so the digits are never Arabic-Indic.
    static func make(randomNumber: () -> Int = { Int.random(in: 0...9999) }) -> String {
        while true {
            let code = String(format: "%04d", randomNumber() % 10000)
            if !excludedCodes.contains(code) { return code }
        }
    }
}
