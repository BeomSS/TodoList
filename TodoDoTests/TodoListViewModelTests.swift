import Foundation
import XCTest
@testable import TodoDo

/// TODO 메인 ViewModel 동작을 검증하는 테스트 집합입니다.
@MainActor
final class TodoListViewModelTests: XCTestCase {
    // 테스트마다 독립적인 메모리 저장소를 생성합니다.
    private func makeStore() -> InMemoryTodoStore {
        InMemoryTodoStore()
    }

    // addTodo 호출 시 진행중 목록에 새 항목이 추가되는지 검증합니다.
    func test_addTodo_appendsNewItemToInProgressList() {
        let viewModel = TodoListViewModel(
            initialItems: [],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler()
        )

        viewModel.addTodo(title: "새 할 일", endDate: nil, reminderOffsets: [])

        XCTAssertEqual(viewModel.inProgressItems.count, 1)
        XCTAssertEqual(viewModel.inProgressItems.first?.title, "새 할 일")
        XCTAssertEqual(viewModel.completedItems.count, 0)
    }

    // 완료 토글 시 진행중 목록에서 빠지고 완료 목록으로 이동하는지 검증합니다.
    func test_toggleCompletion_movesItemToCompletedList() async {
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "테스트", isCompleted: false)
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler()
        )

        await viewModel.toggleCompletion(for: 1)

        XCTAssertTrue(viewModel.inProgressItems.isEmpty)
        XCTAssertEqual(viewModel.completedItems.count, 1)
        XCTAssertEqual(viewModel.completedItems.first?.id, 1)
        XCTAssertNotNil(viewModel.completedItems.first?.completedAt)
    }

    // 제목 수정 시 진행중 목록의 해당 항목 제목이 갱신되는지 검증합니다.
    func test_updateTodo_updatesItemTitle() {
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "수정 전", isCompleted: false)
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler()
        )

        viewModel.updateTodo(id: 1, title: "수정 후", endDate: nil, reminderOffsets: [])

        XCTAssertEqual(viewModel.inProgressItems.first?.title, "수정 후")
    }

    // 삭제 후 취소 시 진행중 목록에 원래 위치로 복구되는지 검증합니다.
    func test_delete_and_undo_restoresItem() {
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false),
                TodoItemViewData(id: 2, title: "B", isCompleted: false)
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler()
        )

        viewModel.deleteTodo(id: 1)
        XCTAssertEqual(viewModel.inProgressItems.map(\.id), [2])

        viewModel.undoLastDeletion()
        XCTAssertEqual(viewModel.inProgressItems.map(\.id), [1, 2])
    }

    // 진행중 목록 이동 시 완료 목록은 유지되고 진행중 순서만 변경되는지 검증합니다.
    func test_moveTodos_reordersOnlyInProgressItems() {
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false),
                TodoItemViewData(id: 2, title: "B", isCompleted: true, completedAt: Date()),
                TodoItemViewData(id: 3, title: "C", isCompleted: false)
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler()
        )

        // 진행중 목록은 [1, 3]이며 첫 항목을 뒤로 이동합니다.
        viewModel.moveTodos(fromOffsets: IndexSet(integer: 0), toOffset: 2)

        XCTAssertEqual(viewModel.inProgressItems.map(\.id), [3, 1])
        XCTAssertEqual(viewModel.completedItems.map(\.id), [2])
    }

    // 커스텀 드롭 경로(ID 기반 이동)에서도 진행중 순서만 변경되는지 검증합니다.
    func test_moveInProgressTodo_reordersByIDs() {
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false),
                TodoItemViewData(id: 2, title: "B", isCompleted: true, completedAt: Date()),
                TodoItemViewData(id: 3, title: "C", isCompleted: false)
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler()
        )

        viewModel.moveInProgressTodo(draggingID: 1, to: 3)

        XCTAssertEqual(viewModel.inProgressItems.map(\.id), [3, 1])
        XCTAssertEqual(viewModel.completedItems.map(\.id), [2])
    }

    // 커스텀 파티셔닝 전략 주입 시 ViewModel이 전략 결과를 그대로 반영하는지 검증합니다.
    func test_init_usesInjectedPartitioner() {
        let partitioner = TodoListPartitionerSpy()
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false),
                TodoItemViewData(id: 2, title: "B", isCompleted: true, completedAt: Date())
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler(),
            listPartitioner: partitioner
        )

        XCTAssertEqual(partitioner.partitionCallCount, 1)
        XCTAssertEqual(viewModel.inProgressItems.map(\.id), [100])
        XCTAssertEqual(viewModel.completedItems.map(\.id), [200])
    }

    // 위젯 스냅샷 저장 구현체를 주입하면 초기 동기화 시점에 호출되는지 검증합니다.
    func test_init_usesInjectedWidgetSnapshotWriter() {
        let writer = WidgetSnapshotWriterSpy()
        _ = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false)
            ],
            store: makeStore(),
            reminderScheduler: NoOpTodoReminderScheduler(),
            todayWidgetSnapshotWriter: writer
        )

        XCTAssertEqual(writer.saveCallCount, 1)
    }
}

// 테스트에서 알림 스케줄링 호출 여부만 검증하기 위한 spy 구현입니다.
final class ReminderSchedulerSpy: TodoReminderScheduling {
    // replaceReminders가 호출된 TODO ID 목록입니다.
    private(set) var replacedTodoIDs: [Int] = []
    // removeReminders가 호출된 TODO ID 목록입니다.
    private(set) var removedTodoIDs: [Int] = []
    // removeAllReminders 호출 횟수입니다.
    private(set) var removeAllCallCount = 0

    func replaceReminders(for item: TodoItemViewData) {
        replacedTodoIDs.append(item.id)
    }

    func removeReminders(forTodoID id: Int) {
        removedTodoIDs.append(id)
    }

    func removeAllReminders() {
        removeAllCallCount += 1
    }
}

// 테스트에서 도메인 이벤트 발행 여부를 검증하기 위한 spy 구현입니다.
final class TodoEventPublisherSpy: TodoEventPublishing {
    // 발행된 이벤트 목록입니다.
    private(set) var events: [TodoEvent] = []

    func publish(_ event: TodoEvent) {
        events.append(event)
    }
}

// 테스트에서 주입 가능한 목록 분리 전략 spy입니다.
final class TodoListPartitionerSpy: TodoListPartitioning {
    // partition 호출 횟수입니다.
    private(set) var partitionCallCount = 0

    func partition(items: [TodoItemViewData]) -> TodoListPartition {
        partitionCallCount += 1
        return TodoListPartition(
            inProgress: [TodoItemViewData(id: 100, title: "P", isCompleted: false)],
            completed: [TodoItemViewData(id: 200, title: "C", isCompleted: true, completedAt: Date())]
        )
    }
}

// 테스트에서 위젯 스냅샷 저장 호출 여부를 검증하기 위한 spy 구현입니다.
final class WidgetSnapshotWriterSpy: TodayTodoWidgetSnapshotWriting {
    // save 호출 횟수입니다.
    private(set) var saveCallCount = 0

    func save(items: [TodoItemViewData]) {
        saveCallCount += 1
    }
}

// 로컬 서비스 레벨의 규칙을 직접 검증합니다.
/// 로컬 TODO 서비스 비즈니스 규칙을 검증하는 테스트 집합입니다.
final class LocalTodoServiceTests: XCTestCase {
    // 완료 체크/해제 시 completedAt이 올바르게 반영되는지 검증합니다.
    func test_toggleCompletion_updatesCompletedAt() {
        let now = Date()
        let store = InMemoryTodoStore(
            initialState: LocalTodoPersistedState(
                items: [
                    TodoItemViewData(id: 1, title: "A", isCompleted: false, completedAt: nil)
                ],
                nextLocalID: -2
            )
        )

        let service = LocalTodoService(store: store, nowProvider: { now })

        service.toggleCompletion(id: 1)
        XCTAssertTrue(service.items.first?.isCompleted == true)
        XCTAssertEqual(service.items.first?.completedAt, now)

        service.toggleCompletion(id: 1)
        XCTAssertTrue(service.items.first?.isCompleted == false)
        XCTAssertNil(service.items.first?.completedAt)
    }

    // 입력값 정규화(연속 공백/줄바꿈 제거)가 적용되는지 검증합니다.
    func test_addTodo_normalizesTitle() {
        let store = InMemoryTodoStore()
        let service = LocalTodoService(store: store)

        service.addTodo(title: "  장보기 \n  우유  사기  ", endDate: nil, reminderOffsets: [])

        XCTAssertEqual(service.items.first?.title, "장보기 우유 사기")
    }

    // 제목 수정 시 정규화가 적용되고 기존 상태(완료 여부/완료일)가 유지되는지 검증합니다.
    func test_updateTodo_normalizesAndPreservesState() {
        let now = Date()
        let store = InMemoryTodoStore(
            initialState: LocalTodoPersistedState(
                items: [
                    TodoItemViewData(id: 1, title: "원본", isCompleted: true, completedAt: now)
                ],
                nextLocalID: -2
            )
        )
        let service = LocalTodoService(store: store)

        service.updateTodo(id: 1, title: "  수정된 \n 제목  ", endDate: nil, reminderOffsets: [])

        XCTAssertEqual(service.items.first?.title, "수정된 제목")
        XCTAssertEqual(service.items.first?.isCompleted, true)
        XCTAssertEqual(service.items.first?.completedAt, now)
    }

    // 정렬 이동 시 순서가 바뀌고 저장되는지 검증합니다.
    func test_moveTodos_changesOrderAndPersists() {
        let store = InMemoryTodoStore(
            initialState: LocalTodoPersistedState(
                items: [
                    TodoItemViewData(id: 1, title: "A", isCompleted: false),
                    TodoItemViewData(id: 2, title: "B", isCompleted: false),
                    TodoItemViewData(id: 3, title: "C", isCompleted: false)
                ],
                nextLocalID: -1
            )
        )
        let service = LocalTodoService(store: store)

        service.moveTodos(fromOffsets: IndexSet(integer: 2), toOffset: 0)

        XCTAssertEqual(service.items.map(\.id), [3, 1, 2])
        XCTAssertEqual(store.loadState()?.items.map(\.id), [3, 1, 2])
    }

    // ID 순서 기반 재정렬이 전체 목록에 반영되는지 검증합니다.
    func test_reorderTodos_appliesOrderedIDs() {
        let store = InMemoryTodoStore(
            initialState: LocalTodoPersistedState(
                items: [
                    TodoItemViewData(id: 1, title: "A", isCompleted: false),
                    TodoItemViewData(id: 2, title: "B", isCompleted: true, completedAt: Date()),
                    TodoItemViewData(id: 3, title: "C", isCompleted: false)
                ],
                nextLocalID: -4
            )
        )

        let service = LocalTodoService(store: store)
        service.reorderTodos(orderedIDs: [3, 1, 2])

        XCTAssertEqual(service.items.map(\.id), [3, 1, 2])
        XCTAssertEqual(store.loadState()?.items.map(\.id), [3, 1, 2])
    }

    // 완료 처리 시 해당 항목의 알림이 교체(=실질적으로 해제)되는지 검증합니다.
    func test_toggleCompletion_triggersReminderRefresh() {
        let spy = ReminderSchedulerSpy()
        let service = LocalTodoService(
            store: InMemoryTodoStore(),
            reminderScheduler: spy,
            initialItems: [
                TodoItemViewData(
                    id: 1,
                    title: "A",
                    endDate: Date().addingTimeInterval(3_600),
                    reminderOffsets: [300, 600],
                    isCompleted: false
                )
            ]
        )

        service.toggleCompletion(id: 1)

        XCTAssertTrue(spy.replacedTodoIDs.contains(1))
    }

    // 삭제 시 해당 항목 알림이 제거되는지 검증합니다.
    func test_deleteTodo_removesReminder() {
        let spy = ReminderSchedulerSpy()
        let service = LocalTodoService(
            store: InMemoryTodoStore(),
            reminderScheduler: spy,
            initialItems: [
                TodoItemViewData(
                    id: 1,
                    title: "A",
                    endDate: Date().addingTimeInterval(3_600),
                    reminderOffsets: [300],
                    isCompleted: false
                )
            ]
        )

        service.deleteTodo(id: 1)

        XCTAssertTrue(spy.removedTodoIDs.contains(1))
    }

    // 서비스 동작 시 도메인 이벤트가 발행되는지 검증합니다.
    func test_addTodo_publishesAddedEvent() {
        let publisher = TodoEventPublisherSpy()
        let service = LocalTodoService(
            store: InMemoryTodoStore(),
            nowProvider: { Date(timeIntervalSince1970: 123) },
            eventPublisher: publisher
        )

        service.addTodo(title: "이벤트 테스트", endDate: nil, reminderOffsets: [])

        XCTAssertEqual(publisher.events.count, 1)
        XCTAssertEqual(publisher.events.first?.kind, .added)
        XCTAssertEqual(publisher.events.first?.todoID, -1)
        XCTAssertEqual(publisher.events.first?.occurredAt, Date(timeIntervalSince1970: 123))
    }
}

// CoreData 저장소 자체 동작을 검증합니다.
/// CoreData 저장소의 저장/복원 동작을 검증하는 테스트 집합입니다.
final class CoreDataTodoStoreTests: XCTestCase {
    // 저장 후 로드 시 동일 상태로 복원되는지 검증합니다.
    func test_save_and_load_roundTrip() {
        let store = CoreDataTodoStore(inMemory: true)
        let state = LocalTodoPersistedState(
            items: [
                TodoItemViewData(id: -1, title: "A", reminderOffsets: [300, 600], isCompleted: false),
                TodoItemViewData(id: -2, title: "B", isCompleted: true, completedAt: Date())
            ],
            nextLocalID: -3
        )

        store.saveState(state)
        let loaded = store.loadState()

        XCTAssertEqual(loaded?.nextLocalID, -3)
        XCTAssertEqual(loaded?.items.count, 2)
        XCTAssertEqual(loaded?.items.first?.id, -1)
        XCTAssertEqual(loaded?.items.first?.title, "A")
        XCTAssertEqual(loaded?.items.first?.reminderOffsets, [300, 600])
    }

    // 새 상태를 저장하면 누락된 항목이 실제로 삭제되는지 검증합니다.
    func test_save_replacesAndDeletesMissingItems() {
        let store = CoreDataTodoStore(inMemory: true)

        store.saveState(
            LocalTodoPersistedState(
                items: [
                    TodoItemViewData(id: -1, title: "A", isCompleted: false),
                    TodoItemViewData(id: -2, title: "B", isCompleted: false)
                ],
                nextLocalID: -3
            )
        )

        store.saveState(
            LocalTodoPersistedState(
                items: [
                    TodoItemViewData(id: -2, title: "B-updated", isCompleted: true, completedAt: nil)
                ],
                nextLocalID: -3
            )
        )

        let loaded = store.loadState()
        XCTAssertEqual(loaded?.items.count, 1)
        XCTAssertEqual(loaded?.items.first?.id, -2)
        XCTAssertEqual(loaded?.items.first?.title, "B-updated")
        XCTAssertEqual(loaded?.items.first?.isCompleted, true)
    }
}

// 유스케이스 계층의 동작을 검증합니다.
/// UseCase 계층의 서비스 위임 동작을 검증하는 테스트 집합입니다.
final class TodoUseCaseTests: XCTestCase {
    // 추가 유스케이스 실행 시 목록이 갱신되는지 검증합니다.
    func test_addUseCase_addsTodo() {
        let service = LocalTodoService(store: InMemoryTodoStore())
        let addUseCase = DefaultAddTodoUseCase(service: service)
        let fetchUseCase = DefaultFetchTodoListUseCase(service: service)

        addUseCase.execute(title: "유스케이스 테스트", endDate: nil, reminderOffsets: [])

        let items = fetchUseCase.execute()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "유스케이스 테스트")
    }

    // 토글 유스케이스 실행 시 완료 상태가 바뀌는지 검증합니다.
    func test_toggleUseCase_togglesCompletion() {
        let service = LocalTodoService(
            store: InMemoryTodoStore(),
            initialItems: [TodoItemViewData(id: 1, title: "A", isCompleted: false)]
        )
        let toggleUseCase = DefaultToggleTodoCompletionUseCase(service: service)
        let fetchUseCase = DefaultFetchTodoListUseCase(service: service)

        toggleUseCase.execute(id: 1)

        XCTAssertEqual(fetchUseCase.execute().first?.isCompleted, true)
    }

    // 제목 수정 유스케이스 실행 시 제목이 갱신되는지 검증합니다.
    func test_updateTitleUseCase_updatesTitle() {
        let service = LocalTodoService(
            store: InMemoryTodoStore(),
            initialItems: [TodoItemViewData(id: 1, title: "A", isCompleted: false)]
        )
        let updateUseCase = DefaultUpdateTodoUseCase(service: service)
        let fetchUseCase = DefaultFetchTodoListUseCase(service: service)

        updateUseCase.execute(id: 1, title: "A-Updated", endDate: nil, reminderOffsets: [])

        XCTAssertEqual(fetchUseCase.execute().first?.title, "A-Updated")
    }

    // 순서 재정렬 유스케이스 실행 시 목록 순서가 반영되는지 검증합니다.
    func test_reorderUseCase_reordersByIDs() {
        let service = LocalTodoService(
            store: InMemoryTodoStore(),
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false),
                TodoItemViewData(id: 2, title: "B", isCompleted: true, completedAt: Date()),
                TodoItemViewData(id: 3, title: "C", isCompleted: false)
            ]
        )

        let reorderUseCase = DefaultReorderTodoListUseCase(service: service)
        let fetchUseCase = DefaultFetchTodoListUseCase(service: service)

        reorderUseCase.execute(orderedIDs: [3, 1, 2])

        XCTAssertEqual(fetchUseCase.execute().map(\.id), [3, 1, 2])
    }
}
