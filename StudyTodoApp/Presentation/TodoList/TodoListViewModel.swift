import Foundation

// TODO 화면 상태와 사용자 액션을 중재하는 ViewModel입니다.
@MainActor
public final class TodoListViewModel: ObservableObject {
    // 메인 화면(진행중 탭)에 보여줄 TODO 목록입니다.
    @Published public private(set) var inProgressItems: [TodoItemViewData] = []
    // 완료 화면에서 보여줄 TODO 목록입니다.
    @Published public private(set) var completedItems: [TodoItemViewData] = []
    // 삭제 Undo 토스트 상태입니다.
    @Published public private(set) var undoToast: UndoToastState?

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
    // 토스트 자동 닫힘 타이머 작업입니다.
    private var dismissToastTask: Task<Void, Never>?

    // 기본 저장소는 CoreData입니다.
    // 테스트/프리뷰에서는 InMemoryTodoStore 등으로 교체 가능합니다.
    public init(
        initialItems: [TodoItemViewData] = [],
        store: TodoStore = CoreDataTodoStore(),
        nowProvider: @escaping () -> Date = Date.init
    ) {
        let service = LocalTodoService(
            store: store,
            nowProvider: nowProvider,
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

        syncFromService()
    }

    deinit {
        // 화면이 사라질 때 예약된 작업을 정리합니다.
        dismissToastTask?.cancel()
    }

    // 신규 TODO를 추가합니다.
    public func addTodo(title: String, endDate: Date?) {
        addTodoUseCase.execute(title: title, endDate: endDate)
        syncFromService()
    }

    // 기존 TODO 제목/마감일을 수정합니다.
    public func updateTodo(id: Int, title: String, endDate: Date?) {
        updateTodoUseCase.execute(id: id, title: title, endDate: endDate)
        syncFromService()
    }

    // 완료 상태를 토글합니다.
    public func toggleCompletion(for id: Int) async {
        toggleTodoCompletionUseCase.execute(id: id)
        syncFromService()
    }

    // 항목을 삭제하고 Undo 토스트를 노출합니다.
    public func deleteTodo(id: Int) {
        deleteTodoUseCase.execute(id: id)
        syncFromService()
        scheduleToastDismiss()
    }

    // 목록 순서를 변경합니다.
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

        let orderedIDs = reorderedInProgress.map(\.id) + completedItems.map(\.id)
        reorderTodoListUseCase.execute(orderedIDs: orderedIDs)
        syncFromService()
    }

    // 진행중 목록에서 드래그 항목을 대상 항목 위치로 직접 이동합니다.
    // 커스텀 onDrop 정렬에서 IndexSet/toOffset 보정보다 안정적으로 동작합니다.
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

        let orderedIDs = reorderedInProgress.map(\.id) + completedItems.map(\.id)
        reorderTodoListUseCase.execute(orderedIDs: orderedIDs)
        syncFromService()
    }

    // 마지막 삭제를 복구합니다.
    public func undoLastDeletion() {
        dismissToastTask?.cancel()
        undoTodoDeletionUseCase.execute()
        syncFromService()
    }

    // 앱의 TODO 데이터를 전체 삭제합니다.
    public func clearAllAppData() {
        dismissToastTask?.cancel()
        clearAllTodosUseCase.execute()
        syncFromService()
    }

    // 서비스 상태를 Published 값으로 반영합니다.
    private func syncFromService() {
        let allItems = fetchTodoListUseCase.execute()
        inProgressItems = allItems.filter { $0.isCompleted == false }
        completedItems = allItems.filter(\.isCompleted)
        undoToast = readTodoScreenStateUseCase.readUndoToast()
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
