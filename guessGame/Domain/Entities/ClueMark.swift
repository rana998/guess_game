/// One tagged image on the describer's board (handoff `roundState.marks[{tileId, badge}]`).
/// Until real images exist, an image is identified by its board tile.
struct ClueMark: Hashable {
    let tileIndex: Int
    let tag: ClueTag
}
