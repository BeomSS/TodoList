import Foundation

// 서비스 기반 조회 유스케이스 구현입니다.
public struct DefaultFetchTodoListUseCase: FetchTodoListUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute() -> [TodoItemViewData] {
        service.items
    }
}

// 서비스 기반 추가 유스케이스 구현입니다.
public struct DefaultAddTodoUseCase: AddTodoUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute(title: String, endDate: Date?) {
        service.addTodo(title: title, endDate: endDate)
    }
}

// 서비스 기반 제목/마감일 수정 유스케이스 구현입니다.
public struct DefaultUpdateTodoUseCase: UpdateTodoUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute(id: Int, title: String, endDate: Date?) {
        service.updateTodo(id: id, title: title, endDate: endDate)
    }
}

// 서비스 기반 완료 토글 유스케이스 구현입니다.
public struct DefaultToggleTodoCompletionUseCase: ToggleTodoCompletionUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute(id: Int) {
        service.toggleCompletion(id: id)
    }
}

// 서비스 기반 삭제 유스케이스 구현입니다.
public struct DefaultDeleteTodoUseCase: DeleteTodoUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute(id: Int) {
        service.deleteTodo(id: id)
    }
}

// 서비스 기반 순서 변경 유스케이스 구현입니다.
public struct DefaultMoveTodoUseCase: MoveTodoUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute(fromOffsets: IndexSet, toOffset: Int) {
        service.moveTodos(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}

// 서비스 기반 복구 유스케이스 구현입니다.
public struct DefaultUndoTodoDeletionUseCase: UndoTodoDeletionUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute() {
        service.undoLastDeletion()
    }
}

// 서비스 기반 토스트 비움 유스케이스 구현입니다.
public struct DefaultClearUndoToastUseCase: ClearUndoToastUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute() {
        service.clearUndoToast()
    }
}

// 서비스 기반 전체 데이터 삭제 유스케이스 구현입니다.
public struct DefaultClearAllTodosUseCase: ClearAllTodosUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute() {
        service.clearAllTodos()
    }
}

// 서비스 기반 화면 상태 조회 유스케이스 구현입니다.
public struct DefaultReadTodoScreenStateUseCase: ReadTodoScreenStateUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func readUndoToast() -> UndoToastState? {
        service.undoToast
    }
}

// 서비스 기반 전체 순서 재정렬 유스케이스 구현입니다.
public struct DefaultReorderTodoListUseCase: ReorderTodoListUseCase {
    private let service: TodoServiceType

    public init(service: TodoServiceType) {
        self.service = service
    }

    public func execute(orderedIDs: [Int]) {
        service.reorderTodos(orderedIDs: orderedIDs)
    }
}
