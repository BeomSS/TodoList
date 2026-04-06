import Foundation

/// 앱 의존성 조립(Dependency Injection) 진입점입니다.
/// 앱 전역에서 재사용할 서비스/저장소를 구성하고 화면 단위 객체를 생성합니다.
public struct AppDIContainer {
    /// 앱 전역에서 재사용하는 기본 DI 컨테이너입니다.
    /// AppIntent/Siri 동작에서도 동일한 저장소 구성을 사용하기 위해 제공합니다.
    public static let shared = AppDIContainer()

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

    /// 시스템 인텐트(Siri/단축어)에서 호출할 TODO 추가 진입점입니다.
    /// - Parameters:
    ///   - title: 추가할 할 일 제목입니다.
    ///   - endDate: 선택 마감 시각입니다.
    /// - Returns: 실제로 항목이 추가되면 `true`, 입력 정규화 등으로 무시되면 `false`입니다.
    public func addTodoFromSystem(title: String, endDate: Date?) -> Bool {
        // 인텐트 실행 시점에도 동일한 도메인 서비스 규칙을 재사용합니다.
        let service = LocalTodoService(
            store: store,
            reminderScheduler: LocalNotificationTodoReminderScheduler(),
            eventPublisher: eventPublisher
        )
        let fetchTodoListUseCase = DefaultFetchTodoListUseCase(service: service)
        let addTodoUseCase = DefaultAddTodoUseCase(service: service)

        let beforeCount = fetchTodoListUseCase.execute().count
        addTodoUseCase.execute(title: title, endDate: endDate, reminderOffsets: [])
        let items = fetchTodoListUseCase.execute()

        // Siri로 추가된 결과도 위젯에 즉시 반영되도록 스냅샷을 갱신합니다.
        TodayTodoWidgetSnapshotStore().save(items: items)
        return items.count > beforeCount
    }
}
