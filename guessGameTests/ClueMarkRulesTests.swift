import XCTest
@testable import guessGame

final class ClueMarkRulesTests: XCTestCase {
    private func round(marks: [ClueMark] = [], phase: RoundPhase = .describing) -> Round {
        Round(index: 0, describerId: "player-0", phase: phase, marks: marks)
    }

    /// Marks tiles 0, 1, 2… with the given tags in order.
    private func marks(_ tags: [ClueTag]) -> [ClueMark] {
        tags.enumerated().map { position, tag in ClueMark(tileIndex: position, tag: tag) }
    }

    func testLimitsAreOneQuestionTenCubesOneExclamation() {
        XCTAssertEqual(ClueMarkRules.limit(for: .mainIdea), 1)
        XCTAssertEqual(ClueMarkRules.limit(for: .detail), 10)
        XCTAssertEqual(ClueMarkRules.limit(for: .secondaryIdea), 1)
    }

    func testRemainingCubesCountDown() {
        XCTAssertEqual(ClueMarkRules.remaining(.detail, in: round()), 10)
        XCTAssertEqual(ClueMarkRules.remaining(.detail, in: round(marks: marks([.detail, .detail, .detail]))), 7)
        XCTAssertEqual(ClueMarkRules.remaining(.detail, in: round(marks: marks(Array(repeating: .detail, count: 10)))), 0)
    }

    func testTenthCubeIsAllowedAndEleventhIsRejected() {
        let nineCubes = round(marks: marks(Array(repeating: .detail, count: 9)))
        XCTAssertNil(ClueMarkRules.rejection(placing: .detail, onTile: 20, in: nineCubes))
        let tenCubes = round(marks: marks(Array(repeating: .detail, count: 10)))
        XCTAssertEqual(ClueMarkRules.rejection(placing: .detail, onTile: 20, in: tenCubes), .limitReached)
    }

    func testSecondQuestionMarkIsRejected() {
        let round = round(marks: marks([.mainIdea]))
        XCTAssertEqual(ClueMarkRules.rejection(placing: .mainIdea, onTile: 5, in: round), .limitReached)
    }

    func testSecondExclamationIsRejected() {
        let round = round(marks: marks([.secondaryIdea]))
        XCTAssertEqual(ClueMarkRules.rejection(placing: .secondaryIdea, onTile: 5, in: round), .limitReached)
    }

    func testCapsAreIndependent() {
        // Using up the cubes leaves "?" and "!" available, and vice versa.
        let tenCubes = round(marks: marks(Array(repeating: .detail, count: 10)))
        XCTAssertNil(ClueMarkRules.rejection(placing: .mainIdea, onTile: 20, in: tenCubes))
        XCTAssertNil(ClueMarkRules.rejection(placing: .secondaryIdea, onTile: 20, in: tenCubes))
        let questionAndExclamation = round(marks: marks([.mainIdea, .secondaryIdea]))
        XCTAssertEqual(ClueMarkRules.remaining(.detail, in: questionAndExclamation), 10)
    }

    func testAllTwelveTagsFitInOneRound() {
        let tags: [ClueTag] = [.mainIdea] + Array(repeating: .detail, count: 10) + [.secondaryIdea]
        var round = round()
        for (tileIndex, tag) in tags.enumerated() {
            XCTAssertNil(ClueMarkRules.rejection(placing: tag, onTile: tileIndex, in: round))
            round.marks.append(ClueMark(tileIndex: tileIndex, tag: tag))
        }
        XCTAssertFalse(ClueMarkRules.hasAnyRemaining(in: round))
        for tag in ClueTag.allCases {
            XCTAssertEqual(ClueMarkRules.rejection(placing: tag, onTile: 31, in: round), .limitReached)
        }
    }

    func testCubesMayComeBeforeTheQuestionMark() {
        XCTAssertNil(ClueMarkRules.rejection(placing: .mainIdea, onTile: 3, in: round(marks: marks([.detail, .detail]))))
    }

    func testAMarkedTileTakesNoSecondTag() {
        let round = round(marks: [ClueMark(tileIndex: 6, tag: .detail)])
        XCTAssertEqual(ClueMarkRules.rejection(placing: .mainIdea, onTile: 6, in: round), .tileAlreadyMarked)
    }

    func testTilesOutsideTheBoardAreRejected() {
        XCTAssertEqual(ClueMarkRules.rejection(placing: .detail, onTile: -1, in: round()), .tileOutOfRange)
        XCTAssertEqual(ClueMarkRules.rejection(placing: .detail, onTile: 32, in: round()), .tileOutOfRange)
        XCTAssertNil(ClueMarkRules.rejection(placing: .detail, onTile: 31, in: round()))
    }

    func testNothingIsPlacedOutsideDescribing() {
        for phase in [RoundPhase.choosingWord, .wordDrawn, .ended(.timeUp)] {
            XCTAssertEqual(ClueMarkRules.rejection(placing: .detail, onTile: 0, in: round(phase: phase)), .notDescribing)
        }
    }

    func testHasAnyRemainingWhileAnyTagIsLeft() {
        XCTAssertTrue(ClueMarkRules.hasAnyRemaining(in: round()))
        XCTAssertTrue(ClueMarkRules.hasAnyRemaining(in: round(marks: marks([.mainIdea, .secondaryIdea]))))
    }
}
