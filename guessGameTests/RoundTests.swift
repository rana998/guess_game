import XCTest
@testable import guessGame

final class RoundTests: XCTestCase {
    private let startDate = GameFixtures.startDate

    private func round(marks: [ClueMark] = [], endsAt: Date? = nil, endedAt: Date? = nil) -> Round {
        Round(index: 0, describerId: "player-0", phase: .describing, endsAt: endsAt, endedAt: endedAt, marks: marks)
    }

    // MARK: - Marks

    func testCountsEachTagSeparately() {
        let marks = [
            ClueMark(tileIndex: 0, tag: .detail),
            ClueMark(tileIndex: 1, tag: .mainIdea),
            ClueMark(tileIndex: 2, tag: .detail),
        ]
        let round = round(marks: marks)
        XCTAssertEqual(round.count(of: .detail), 2)
        XCTAssertEqual(round.count(of: .mainIdea), 1)
        XCTAssertEqual(round.count(of: .secondaryIdea), 0)
    }

    func testFindsTheMarkOnATile() {
        let round = round(marks: [ClueMark(tileIndex: 7, tag: .secondaryIdea)])
        XCTAssertEqual(round.mark(onTile: 7), ClueMark(tileIndex: 7, tag: .secondaryIdea))
        XCTAssertNil(round.mark(onTile: 8))
    }

    func testMainIdeaMarksKeepPlacementOrderAcrossBothTags() {
        let marks = [
            ClueMark(tileIndex: 5, tag: .detail),
            ClueMark(tileIndex: 9, tag: .secondaryIdea),
            ClueMark(tileIndex: 2, tag: .mainIdea),
            ClueMark(tileIndex: 30, tag: .detail),
        ]
        XCTAssertEqual(round(marks: marks).mainIdeaMarks.map(\.tileIndex), [5, 2, 30])
    }

    func testSecondaryIdeaMarkIsTheExclamationTile() {
        XCTAssertNil(round(marks: [ClueMark(tileIndex: 1, tag: .detail)]).secondaryIdeaMark)
        XCTAssertEqual(round(marks: [ClueMark(tileIndex: 4, tag: .secondaryIdea)]).secondaryIdeaMark?.tileIndex, 4)
    }

    func testHasAnyMark() {
        XCTAssertFalse(round().hasAnyMark)
        XCTAssertTrue(round(marks: [ClueMark(tileIndex: 0, tag: .secondaryIdea)]).hasAnyMark)
    }

    // MARK: - Phase

    func testEndReasonOnlyWhenEnded() {
        var round = round()
        XCTAssertNil(round.endReason)
        XCTAssertFalse(round.isEnded)
        round.phase = .ended(.timeUp)
        XCTAssertEqual(round.endReason, .timeUp)
        XCTAssertTrue(round.isEnded)
        XCTAssertFalse(round.isDescribing)
    }

    // MARK: - Remaining time

    func testNoRemainingTimeBeforeDescribingStarts() {
        XCTAssertNil(round().remainingSeconds(at: startDate))
    }

    func testRemainingSecondsRoundUp() {
        let round = round(endsAt: startDate.addingTimeInterval(60))
        XCTAssertEqual(round.remainingSeconds(at: startDate), 60)
        XCTAssertEqual(round.remainingSeconds(at: startDate.addingTimeInterval(13.8)), 47)
        XCTAssertEqual(round.remainingSeconds(at: startDate.addingTimeInterval(59.5)), 1)
    }

    func testRemainingSecondsNeverGoBelowZero() {
        let round = round(endsAt: startDate.addingTimeInterval(60))
        XCTAssertEqual(round.remainingSeconds(at: startDate.addingTimeInterval(60)), 0)
        XCTAssertEqual(round.remainingSeconds(at: startDate.addingTimeInterval(500)), 0)
    }

    func testRemainingSecondsFreezeWhenTheRoundEnds() {
        let round = round(endsAt: startDate.addingTimeInterval(60), endedAt: startDate.addingTimeInterval(20))
        XCTAssertEqual(round.remainingSeconds(at: startDate.addingTimeInterval(45)), 40)
    }
}
