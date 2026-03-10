import Foundation

/// 앱 의존성 조립(Dependency Injection) 진입점입니다.
/// 앱 전역에서 재사용할 서비스/저장소를 구성하고 화면 단위 객체를 생성합니다.
public struct AppDIContainer {
    // 앱 기본 저장소입니다. 실제 앱은 CoreData 구현을 사용합니다.
    private let store: TodoStore
    // 도메인 이벤트 발행 구현체입니다.
    private let eventPublisher: TodoEventPublishing

    /// DI 컨테이너를 생성합니다.
    /// - Parameters:
    ///   - store: TODO 영속 저장소입니다. 기본값은 `CoreDataTodoStore`입니다.
    ///   - eventPublisher: 도메인 이벤트 발행 구현체입니다.
    public init(
        store: TodoStore = CoreDataTodoStore(),
        eventPublisher: TodoEventPublishing = TodoEventLoggerPublisher()
    ) {
        self.store = store
        self.eventPublisher = eventPublisher
    }

    /// 메인 TODO 화면에 주입할 ViewModel을 생성합니다.
    /// - Returns: 구성된 `TodoListViewModel` 인스턴스입니다.
    @MainActor
    public func makeTodoListViewModel() -> TodoListViewModel {
        TodoListViewModel(
            store: store,
            eventPublisher: eventPublisher
        )
    }
}
