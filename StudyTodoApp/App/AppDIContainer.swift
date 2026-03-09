import Foundation

// 앱 의존성 조립 지점입니다.
public struct AppDIContainer {
    // 앱 기본 저장소입니다. 실제 앱은 CoreData 구현을 사용합니다.
    private let store: TodoStore

    // 기본 초기화 시 CoreData 저장소를 생성합니다.
    public init(store: TodoStore = CoreDataTodoStore()) {
        self.store = store
    }

    // TODO 화면 ViewModel을 생성합니다.
    @MainActor
    public func makeTodoListViewModel() -> TodoListViewModel {
        TodoListViewModel(store: store)
    }
}
