import Foundation

/// 로컬 TODO 비즈니스 로직을 담당하는 서비스입니다.
public final class LocalTodoService: TodoServiceType {
    // MARK: - Dependencies

    // 영속 저장소(CoreData 등)입니다.
    private var store: TodoStore
    // 현재 시각 주입 함수입니다. 테스트에서 고정 시각을 넣기 쉽습니다.
    private let nowProvider: () -> Date
    // 제목 정규화 규칙입니다.
    private let titleNormalizer: TodoTitleNormalizer
    // 마감 알림 스케줄링 구현체입니다.
    private let reminderScheduler: TodoReminderScheduling
    // 도메인 이벤트 발행 구현체입니다.
    private let eventPublisher: TodoEventPublishing

    /// 현재 TODO 목록입니다.
    public private(set) var items: [TodoItemViewData] = []
    /// 로컬 신규 TODO ID 생성기입니다.
    public private(set) var nextLocalID: Int = -1
    /// 마지막 삭제 Undo 토스트 상태입니다.
    public private(set) var undoToast: UndoToastState?

    // MARK: - Init

    /// 로컬 TODO 서비스를 생성합니다.
    /// - Parameters:
    ///   - store: 영속 저장소 구현체입니다.
    ///   - nowProvider: 현재 시각 공급자입니다.
    ///   - titleNormalizer: 제목 정규화 규칙입니다.
    ///   - reminderScheduler: 알림 스케줄러 구현체입니다.
    ///   - eventPublisher: 도메인 이벤트 발행 구현체입니다.
    ///   - initialItems: 초기 부트스트랩 항목입니다.
    public init(
        store: TodoStore,
        nowProvider: @escaping () -> Date = Date.init,
        titleNormalizer: TodoTitleNormalizer = TodoTitleNormalizer(),
        reminderScheduler: TodoReminderScheduling = NoOpTodoReminderScheduler(),
        eventPublisher: TodoEventPublishing = NoOpTodoEventPublisher(),
        initialItems: [TodoItemViewData] = []
    ) {
        self.store = store
        self.nowProvider = nowProvider
        self.titleNormalizer = titleNormalizer
        self.reminderScheduler = reminderScheduler
        self.eventPublisher = eventPublisher

        // 저장된 스냅샷이 있으면 우선 복원합니다.
        if let saved = store.loadState() {
            items = saved.items
            nextLocalID = saved.nextLocalID
        } else if !initialItems.isEmpty {
            // 초기 데이터가 주입되면 한 번만 부트스트랩합니다.
            items = initialItems
            nextLocalID = min(-1, (initialItems.map(\.id).min() ?? 0) - 1)
        }

        // 앱 시작 시점에 저장소와 메모리 상태를 동기화합니다.
        persist()
        // 저장된 상태를 기준으로 알림도 한 번 동기화합니다.
        syncAllReminders()
    }

    // MARK: - CRUD

    /// TODO를 추가하고 필요 시 알림을 등록합니다.
    /// - Parameters:
    ///   - title: 할 일 제목입니다.
    ///   - endDate: 마감 시각입니다.
    ///   - reminderOffsets: 알림 오프셋(초) 목록입니다.
    public func addTodo(title: String, endDate: Date?, reminderOffsets: [Int]) {
        // 입력 정규화 후 빈 문자열이면 무시합니다.
        let normalizedTitle = titleNormalizer.normalize(title)
        guard normalizedTitle.isEmpty == false else { return }
        let normalizedOffsets = normalizeReminderOffsets(reminderOffsets)

        let newItem = TodoItemViewData(
            id: nextLocalID,
            title: normalizedTitle,
            endDate: endDate,
            reminderOffsets: normalizedOffsets,
            isCompleted: false,
            completedAt: nil
        )

        // 최신 항목이 위로 오도록 앞쪽에 삽입합니다.
        nextLocalID -= 1
        items.insert(newItem, at: 0)
        persist()
        // 신규 항목 알림을 등록합니다.
        reminderScheduler.replaceReminders(for: newItem)
        emitEvent(kind: .added, todoID: newItem.id)
    }

    /// TODO 제목/마감일/알림을 수정합니다.
    /// - Parameters:
    ///   - id: 수정 대상 TODO ID입니다.
    ///   - title: 변경할 제목입니다.
    ///   - endDate: 변경할 마감 시각입니다.
    ///   - reminderOffsets: 변경할 알림 오프셋(초) 목록입니다.
    public func updateTodo(id: Int, title: String, endDate: Date?, reminderOffsets: [Int]) {
        let normalizedTitle = titleNormalizer.normalize(title)
        guard normalizedTitle.isEmpty == false else { return }
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let normalizedOffsets = normalizeReminderOffsets(reminderOffsets)

        let current = items[index]
        items[index] = TodoItemViewData(
            id: current.id,
            title: normalizedTitle,
            endDate: endDate,
            reminderOffsets: normalizedOffsets,
            isCompleted: current.isCompleted,
            completedAt: current.completedAt
        )
        persist()
        // 수정된 정보 기준으로 알림을 재등록합니다.
        reminderScheduler.replaceReminders(for: items[index])
        emitEvent(kind: .updated, todoID: current.id)
    }

    /// TODO 완료 상태를 토글하고 알림 상태를 갱신합니다.
    /// - Parameter id: 토글 대상 TODO ID입니다.
    public func toggleCompletion(id: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let current = items[index]
        let newCompleted = !current.isCompleted
        let completedAt = newCompleted ? nowProvider() : nil

        // 불변 모델을 재생성해 상태를 치환합니다.
        items[index] = TodoItemViewData(
            id: current.id,
            title: current.title,
            endDate: current.endDate,
            reminderOffsets: current.reminderOffsets,
            isCompleted: newCompleted,
            completedAt: completedAt
        )

        persist()
        // 완료되면 알림이 제거되고, 완료 해제되면 조건에 맞는 알림이 다시 등록됩니다.
        reminderScheduler.replaceReminders(for: items[index])
        emitEvent(kind: .toggledCompletion, todoID: current.id)
    }

    /// TODO를 삭제하고 Undo 상태 및 알림 상태를 갱신합니다.
    /// - Parameter id: 삭제 대상 TODO ID입니다.
    public func deleteTodo(id: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let removed = items.remove(at: index)
        undoToast = UndoToastState(
            message: "\"\(removed.title)\" 삭제됨",
            deletedItem: removed,
            deletedIndex: index
        )

        // 삭제는 즉시 저장하고, Undo 가능 상태를 함께 유지합니다.
        persist()
        // 삭제된 항목의 예약 알림을 즉시 해제합니다.
        reminderScheduler.removeReminders(forTodoID: removed.id)
        emitEvent(kind: .deleted, todoID: removed.id)
    }

    // MARK: - Ordering

    /// 드래그 정렬 결과를 반영해 저장합니다.
    /// - Parameters:
    ///   - fromOffsets: 원본 인덱스 집합입니다.
    ///   - toOffset: 이동 목적지 인덱스입니다.
    public func moveTodos(fromOffsets: IndexSet, toOffset: Int) {
        guard fromOffsets.isEmpty == false else { return }

        // IndexSet 이동 규칙을 서비스 계층에서 직접 구현해 UI 프레임워크 의존을 없앱니다.
        let sourceIndexes = fromOffsets.sorted()
        let movingItems = sourceIndexes.map { items[$0] }

        // 뒤에서부터 제거해야 인덱스 붕괴를 피할 수 있습니다.
        for index in sourceIndexes.reversed() {
            items.remove(at: index)
        }

        // 제거된 항목이 목적지보다 앞에 있었다면 목적지 인덱스를 보정합니다.
        var adjustedDestination = toOffset
        for index in sourceIndexes where index < toOffset {
            adjustedDestination -= 1
        }
        adjustedDestination = min(max(adjustedDestination, 0), items.count)

        items.insert(contentsOf: movingItems, at: adjustedDestination)
        persist()
        emitEvent(kind: .reordered, todoID: nil)
    }

    /// 전달받은 ID 순서대로 전체 목록을 재배열합니다.
    /// - Parameter orderedIDs: 최종 순서대로 정렬된 TODO ID 목록입니다.
    public func reorderTodos(orderedIDs: [Int]) {
        guard orderedIDs.isEmpty == false else { return }

        let currentByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        var reordered: [TodoItemViewData] = []
        reordered.reserveCapacity(items.count)

        // 요청된 순서대로 기존 항목을 재배치합니다.
        for id in orderedIDs {
            guard let item = currentByID[id] else { continue }
            reordered.append(item)
        }

        // 누락된 항목이 있으면 기존 순서를 유지해 뒤에 붙입니다.
        let orderedSet = Set(orderedIDs)
        for item in items where orderedSet.contains(item.id) == false {
            reordered.append(item)
        }

        guard reordered.isEmpty == false else { return }
        items = reordered
        persist()
        emitEvent(kind: .reordered, todoID: nil)
    }

    // MARK: - Undo / Reset

    /// 마지막 삭제를 복구하고 알림 상태를 갱신합니다.
    public func undoLastDeletion() {
        guard let undoToast else { return }

        // 인덱스 범위를 보정해 안전하게 복원합니다.
        let restoreIndex = min(max(undoToast.deletedIndex, 0), items.count)
        items.insert(undoToast.deletedItem, at: restoreIndex)

        self.undoToast = nil
        persist()
        // 복구되면 항목 상태 기준으로 알림을 다시 맞춥니다.
        reminderScheduler.replaceReminders(for: undoToast.deletedItem)
        emitEvent(kind: .undoDeleted, todoID: undoToast.deletedItem.id)
    }

    /// Undo 토스트 상태를 비웁니다.
    public func clearUndoToast() {
        undoToast = nil
    }

    /// 앱의 TODO 데이터를 전체 삭제하고 초기 상태로 되돌립니다.
    public func clearAllTodos() {
        items.removeAll()
        undoToast = nil
        nextLocalID = -1
        persist()
        // 전체 삭제 시 등록된 TODO 알림도 모두 제거합니다.
        reminderScheduler.removeAllReminders()
        emitEvent(kind: .clearedAll, todoID: nil)
    }

    // MARK: - Private

    // 목록/ID 상태를 저장소에 반영합니다.
    private func persist() {
        store.saveState(
            LocalTodoPersistedState(
                items: items,
                nextLocalID: nextLocalID
            )
        )
    }

    // 중복/정렬 이슈를 막기 위해 오프셋을 정렬+중복제거합니다.
    private func normalizeReminderOffsets(_ reminderOffsets: [Int]) -> [Int] {
        Array(Set(reminderOffsets)).sorted()
    }

    // 현재 메모리의 모든 항목을 기준으로 알림 상태를 일괄 동기화합니다.
    private func syncAllReminders() {
        reminderScheduler.removeAllReminders()
        for item in items {
            reminderScheduler.replaceReminders(for: item)
        }
    }

    // 도메인 이벤트를 일관된 형태로 발행합니다.
    private func emitEvent(kind: TodoEventKind, todoID: Int?) {
        eventPublisher.publish(
            TodoEvent(
                kind: kind,
                todoID: todoID,
                occurredAt: nowProvider()
            )
        )
    }
}
