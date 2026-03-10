import Foundation

/// 테스트/프리뷰에서 사용하는 메모리 저장소입니다.
/// 앱 재시작 후 유지되지 않으며, 런타임 동안만 상태를 보관합니다.
public final class InMemoryTodoStore: TodoStore {
    private var persistedState: LocalTodoPersistedState?

    /// 메모리 저장소를 생성합니다.
    /// - Parameter initialState: 시작 시점에 반환할 초기 스냅샷입니다.
    public init(initialState: LocalTodoPersistedState? = nil) {
        persistedState = initialState
    }

    /// 현재 저장된 스냅샷을 반환합니다.
    /// - Returns: 마지막 저장 상태입니다.
    public func loadState() -> LocalTodoPersistedState? {
        persistedState
    }

    /// 메모리 내 스냅샷을 갱신합니다.
    /// - Parameter state: 저장할 상태입니다.
    public func saveState(_ state: LocalTodoPersistedState) {
        persistedState = state
    }
}
