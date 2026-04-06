import Foundation

/// TODO 화면 상태와 사용자 액션을 중재하는 ViewModel입니다.
@MainActor
public final class TodoListViewModel: ObservableObject {
    // MARK: - Published State

    // 메인 화면(진행중 탭)에 보여줄 TODO 목록입니다.
    @Published public private(set) var inProgressItems: [TodoItemViewData] = []
    // 완료 화면에서 보여줄 TODO 목록입니다.
    @Published public private(set) var completedItems: [TodoItemViewData] = []
    // 삭제 Undo 토스트 상태입니다.
    @Published public private(set) var undoToast: UndoToastState?

    // MARK: - Dependencies

    // 목록 조회 유스케이스입니다.
    private let fetchTodoListUseCase: FetchTodoListUseCase
    // 추가 유스케이스입니다.
    private let addTodoUseCase: AddTodoUseCase
    // 제목/마감일 수정 유스케이스입니다.
    private let updateTodoUseCase: UpdateTodoUseCase
    // 완료 토글 유스케이스입니다.
    private let toggleTodoCompletionUseCase: ToggleTodoCompletionUseCase
    // 삭제 유스케이스입니다.
    private let deleteTodoUseCase: DeleteTodoUseCase
    // 전체 순서 재정렬 유스케이스입니다.
    private let reorderTodoListUseCase: ReorderTodoListUseCase
    // 삭제 복구 유스케이스입니다.
    private let undoTodoDeletionUseCase: UndoTodoDeletionUseCase
    // 토스트 비움 유스케이스입니다.
    private let clearUndoToastUseCase: ClearUndoToastUseCase
    // 앱 데이터 전체 삭제 유스케이스입니다.
    private let clearAllTodosUseCase: ClearAllTodosUseCase
    // 화면 상태 조회 유스케이스입니다.
    private let readTodoScreenStateUseCase: ReadTodoScreenStateUseCase
    // 위젯(오늘 할 일) 스냅샷 저장 계약 구현체입니다.
    private let todayWidgetSnapshotWriter: TodayTodoWidgetSnapshotWriting
    // 화면 표시용 진행중/완료 분리 전략입니다.
    private let listPartitioner: TodoListPartitioning
    // 알림 권한 상태 조회기입니다.
    private let reminderPermissionChecker: TodoReminderPermissionChecking
    // 토스트 자동 닫힘 타이머 작업입니다.
    private var dismissToastTask: Task<Void, Never>?

    // MARK: - Init / Deinit

    /// TODO 화면 ViewModel을 생성합니다.
    /// - Parameters:
    ///   - initialItems: 저장소 초기화 전 부트스트랩 항목입니다.
    ///   - store: TODO 영속 저장소 구현체입니다.
    ///   - reminderScheduler: 로컬 알림 스케줄러 구현체입니다.
    ///   - reminderPermissionChecker: 로컬 알림 권한 상태 조회기입니다.
    ///   - eventPublisher: 도메인 이벤트 발행 구현체입니다.
    ///   - todayWidgetSnapshotWriter: 위젯 스냅샷 저장 구현체입니다.
    ///   - listPartitioner: 목록 분리 전략 구현체입니다.
    ///   - nowProvider: 현재 시각 공급자입니다. 테스트에서 고정 시각 주입에 사용합니다.
    public init(
        initialItems: [TodoItemViewData] = [],
        store: TodoStore = CoreDataTodoStore(),
        reminderScheduler: TodoReminderScheduling = LocalNotificationTodoReminderScheduler(),
        reminderPermissionChecker: TodoReminderPermissionChecking = LocalNotificationPermissionChecker(),
        eventPublisher: TodoEventPublishing = NoOpTodoEventPublisher(),
        todayWidgetSnapshotWriter: TodayTodoWidgetSnapshotWriting? = nil,
        listPartitioner: TodoListPartitioning = DefaultTodoListPartitioner(),
        nowProvider: @escaping () -> Date = Date.init
    ) {
        let service = LocalTodoService(
            store: store,
            nowProvider: nowProvider,
            reminderScheduler: reminderScheduler,
            eventPublisher: eventPublisher,
            initialItems: initialItems
        )

        fetchTodoListUseCase = DefaultFetchTodoListUseCase(service: service)
        addTodoUseCase = DefaultAddTodoUseCase(service: service)
        updateTodoUseCase = DefaultUpdateTodoUseCase(service: service)
        toggleTodoCompletionUseCase = DefaultToggleTodoCompletionUseCase(service: service)
        deleteTodoUseCase = DefaultDeleteTodoUseCase(service: service)
        reorderTodoListUseCase = DefaultReorderTodoListUseCase(service: service)
        undoTodoDeletionUseCase = DefaultUndoTodoDeletionUseCase(service: service)
        clearUndoToastUseCase = DefaultClearUndoToastUseCase(service: service)
        clearAllTodosUseCase = DefaultClearAllTodosUseCase(service: service)
        readTodoScreenStateUseCase = DefaultReadTodoScreenStateUseCase(service: service)
        self.todayWidgetSnapshotWriter = todayWidgetSnapshotWriter ?? TodayTodoWidgetSnapshotStore(nowProvider: nowProvider)
        self.listPartitioner = listPartitioner
        self.reminderPermissionChecker = reminderPermissionChecker

        syncFromService()
    }

    deinit {
        // 화면이 사라질 때 예약된 작업을 정리합니다.
        dismissToastTask?.cancel()
    }

    // MARK: - Public Actions

    /// 신규 TODO를 추가합니다.
    /// - Parameters:
    ///   - title: 할 일 제목입니다.
    ///   - endDate: 마감 시각입니다. 없으면 `nil`입니다.
    ///   - reminderOffsets: 마감 기준 알림 오프셋(초) 목록입니다.
    public func addTodo(title: String, endDate: Date?, reminderOffsets: [Int]) {
        addTodoUseCase.execute(title: title, endDate: endDate, reminderOffsets: reminderOffsets)
        syncFromService()
    }

    /// 기존 TODO 제목/마감일/알림 설정을 수정합니다.
    /// - Parameters:
    ///   - id: 수정 대상 TODO ID입니다.
    ///   - title: 변경할 제목입니다.
    ///   - endDate: 변경할 마감 시각입니다.
    ///   - reminderOffsets: 변경할 알림 오프셋(초) 목록입니다.
    public func updateTodo(id: Int, title: String, endDate: Date?, reminderOffsets: [Int]) {
        updateTodoUseCase.execute(id: id, title: title, endDate: endDate, reminderOffsets: reminderOffsets)
        syncFromService()
    }

    /// TODO 완료 상태를 토글합니다.
    /// - Parameter id: 토글 대상 TODO ID입니다.
    public func toggleCompletion(for id: Int) async {
        toggleTodoCompletionUseCase.execute(id: id)
        syncFromService()
    }

    /// TODO를 삭제하고 Undo 토스트 상태를 갱신합니다.
    /// - Parameter id: 삭제 대상 TODO ID입니다.
    public func deleteTodo(id: Int) {
        deleteTodoUseCase.execute(id: id)
        syncFromService()
        scheduleToastDismiss()
    }

    /// 진행중 목록의 순서를 이동합니다.
    /// - Parameters:
    ///   - fromOffsets: 원본 인덱스 집합입니다.
    ///   - toOffset: 이동 목적지 인덱스입니다.
    public func moveTodos(fromOffsets: IndexSet, toOffset: Int) {
        // 화면에는 진행중 목록만 보여주므로, 진행중 구간만 재정렬하고 완료 구간은 뒤에 유지합니다.
        guard fromOffsets.isEmpty == false else { return }
        var reorderedInProgress = inProgressItems

        // UI 프레임워크 의존을 줄이기 위해 IndexSet 이동 규칙을 ViewModel에서 직접 구현합니다.
        let sourceIndexes = fromOffsets.sorted()
        let movingItems = sourceIndexes.map { reorderedInProgress[$0] }
        for index in sourceIndexes.reversed() {
            reorderedInProgress.remove(at: index)
        }

        var adjustedDestination = toOffset
        for index in sourceIndexes where index < toOffset {
            adjustedDestination -= 1
        }
        adjustedDestination = min(max(adjustedDestination, 0), reorderedInProgress.count)
        reorderedInProgress.insert(contentsOf: movingItems, at: adjustedDestination)

        applyReorderedInProgressItems(reorderedInProgress)
    }

    /// 진행중 목록에서 드래그 항목을 대상 항목 위치로 직접 이동합니다.
    /// - Parameters:
    ///   - draggingID: 드래그 중인 TODO ID입니다.
    ///   - destinationID: 드롭 대상 TODO ID입니다.
    public func moveInProgressTodo(draggingID: Int, to destinationID: Int) {
        guard draggingID != destinationID else { return }

        var reorderedInProgress = inProgressItems
        guard
            let fromIndex = reorderedInProgress.firstIndex(where: { $0.id == draggingID }),
            let toIndex = reorderedInProgress.firstIndex(where: { $0.id == destinationID })
        else {
            return
        }

        let movingItem = reorderedInProgress.remove(at: fromIndex)
        reorderedInProgress.insert(movingItem, at: toIndex)

        applyReorderedInProgressItems(reorderedInProgress)
    }

    /// 마지막 삭제 작업을 복구합니다.
    public func undoLastDeletion() {
        dismissToastTask?.cancel()
        undoTodoDeletionUseCase.execute()
        syncFromService()
    }

    /// 앱의 TODO 데이터를 전체 삭제합니다.
    public func clearAllAppData() {
        dismissToastTask?.cancel()
        clearAllTodosUseCase.execute()
        syncFromService()
    }

    /// 알림을 선택한 경우 현재 알림 권한 상태를 조회합니다.
    /// - Parameter reminderOffsets: 사용자가 선택한 알림 오프셋 목록입니다.
    /// - Returns: 권한 상태입니다. 알림 미선택 시 `.authorized`를 반환합니다.
    public func reminderPermissionStatusIfNeeded(reminderOffsets: [Int]) async -> TodoReminderPermissionStatus {
        guard reminderOffsets.isEmpty == false else { return .authorized }
        return await reminderPermissionChecker.currentStatus()
    }

    // MARK: - Internal Sync

    // 서비스 상태를 Published 값으로 반영합니다.
    private func syncFromService() {
        let allItems = fetchTodoListUseCase.execute()
        let partition = listPartitioner.partition(items: allItems)
        inProgressItems = partition.inProgress
        completedItems = partition.completed
        undoToast = readTodoScreenStateUseCase.readUndoToast()
        // 위젯이 최신 \"오늘 할 일\" 상태를 반영하도록 매 동기화 시 스냅샷을 저장합니다.
        todayWidgetSnapshotWriter.save(items: allItems)
    }

    // 진행중 재정렬 결과를 서비스에 반영하고 화면 상태를 다시 동기화합니다.
    private func applyReorderedInProgressItems(_ reorderedInProgress: [TodoItemViewData]) {
        let orderedIDs = reorderedInProgress.map(\.id) + completedItems.map(\.id)
        reorderTodoListUseCase.execute(orderedIDs: orderedIDs)
        syncFromService()
    }

    // Undo 토스트를 4초 후 자동으로 숨깁니다.
    private func scheduleToastDismiss() {
        dismissToastTask?.cancel()

        dismissToastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard Task.isCancelled == false else { return }
            await MainActor.run {
                guard let self else { return }
                self.clearUndoToastUseCase.execute()
                self.syncFromService()
            }
        }
    }
}
