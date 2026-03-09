import Foundation
import XCTest
@testable import StudyTodoApp

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
            store: makeStore()
        )

        viewModel.addTodo(title: "새 할 일", endDate: nil)

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
            store: makeStore()
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
            store: makeStore()
        )

        viewModel.updateTodo(id: 1, title: "수정 후", endDate: nil)

        XCTAssertEqual(viewModel.inProgressItems.first?.title, "수정 후")
    }

    // 삭제 후 취소 시 진행중 목록에 원래 위치로 복구되는지 검증합니다.
    func test_delete_and_undo_restoresItem() {
        let viewModel = TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "A", isCompleted: false),
                TodoItemViewData(id: 2, title: "B", isCompleted: false)
            ],
            store: makeStore()
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
            store: makeStore()
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
            store: makeStore()
        )

        viewModel.moveInProgressTodo(draggingID: 1, to: 3)

        XCTAssertEqual(viewModel.inProgressItems.map(\.id), [3, 1])
        XCTAssertEqual(viewModel.completedItems.map(\.id), [2])
    }
}

// 로컬 서비스 레벨의 규칙을 직접 검증합니다.
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

        service.addTodo(title: "  장보기 \n  우유  사기  ", endDate: nil)

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

        service.updateTodo(id: 1, title: "  수정된 \n 제목  ", endDate: nil)

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
}

// CoreData 저장소 자체 동작을 검증합니다.
final class CoreDataTodoStoreTests: XCTestCase {
    // 저장 후 로드 시 동일 상태로 복원되는지 검증합니다.
    func test_save_and_load_roundTrip() {
        let store = CoreDataTodoStore(inMemory: true)
        let state = LocalTodoPersistedState(
            items: [
                TodoItemViewData(id: -1, title: "A", isCompleted: false),
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
final class TodoUseCaseTests: XCTestCase {
    // 추가 유스케이스 실행 시 목록이 갱신되는지 검증합니다.
    func test_addUseCase_addsTodo() {
        let service = LocalTodoService(store: InMemoryTodoStore())
        let addUseCase = DefaultAddTodoUseCase(service: service)
        let fetchUseCase = DefaultFetchTodoListUseCase(service: service)

        addUseCase.execute(title: "유스케이스 테스트", endDate: nil)

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

        updateUseCase.execute(id: 1, title: "A-Updated", endDate: nil)

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
