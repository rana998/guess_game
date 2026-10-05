import XCTest
@testable import guessGame

final class LocalRoomCodeTests: XCTestCase {
    func testCodesAreAlwaysFourASCIIDigitsAndNeverTheExampleCode() {
        for _ in 0..<10_000 {
            let code = LocalRoomCode.make()
            XCTAssertEqual(code.count, 4)
            XCTAssertTrue(code.allSatisfy { character in ("0"..."9").contains(character) }, code)
            XCTAssertNotEqual(code, "8701")
        }
    }

    func testAnExcludedDrawIsRedrawn() {
        var draws = [8701, 42]
        XCTAssertEqual(LocalRoomCode.make(randomNumber: { draws.removeFirst() }), "0042")
    }

    func testTheExampleCodeIsExcluded() {
        XCTAssertTrue(LocalRoomCode.excludedCodes.contains("8701"))
    }
}
