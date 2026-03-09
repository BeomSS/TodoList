import Foundation

// ViewModel/Service가 의존하는 저장소 인터페이스입니다.
// 구현체는 CoreData, 테스트 메모리 저장소 등으로 교체 가능합니다.
public protocol TodoStore {
    // 저장된 목록/ID 상태를 읽어옵니다.
    func loadState() -> LocalTodoPersistedState?
    // 목록/ID 상태를 저장합니다.
    func saveState(_ state: LocalTodoPersistedState)
}
