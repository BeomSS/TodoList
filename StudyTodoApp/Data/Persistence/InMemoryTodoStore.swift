import Foundation

// 테스트/프리뷰에서 사용하는 메모리 저장소입니다.
// 앱 재시작 후 유지되지 않으며, 런타임 동안만 상태를 보관합니다.
public final class InMemoryTodoStore: TodoStore {
    private var persistedState: LocalTodoPersistedState?

    public init(initialState: LocalTodoPersistedState? = nil) {
        persistedState = initialState
    }

    public func loadState() -> LocalTodoPersistedState? {
        persistedState
    }

    public func saveState(_ state: LocalTodoPersistedState) {
        persistedState = state
    }
}
