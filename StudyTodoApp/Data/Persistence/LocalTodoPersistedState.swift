import Foundation

// 로컬 저장소에 저장할 상태 스냅샷입니다.
// 저장소 구현체 간에 동일한 데이터 계약을 유지하기 위해 사용합니다.
public struct LocalTodoPersistedState: Codable {
    // 화면에 보여줄 TODO 목록입니다.
    public let items: [TodoItemViewData]
    // 로컬 신규 TODO에 사용할 다음 ID입니다. (음수로 감소)
    public let nextLocalID: Int
}
