import Foundation

// 현재 TODO 목록을 조회하는 유스케이스 계약입니다.
public protocol FetchTodoListUseCase {
    func execute() -> [TodoItemViewData]
}

// TODO를 추가하는 유스케이스 계약입니다.
public protocol AddTodoUseCase {
    func execute(title: String, endDate: Date?)
}

// TODO 제목/마감일을 수정하는 유스케이스 계약입니다.
public protocol UpdateTodoUseCase {
    func execute(id: Int, title: String, endDate: Date?)
}

// TODO 완료 상태를 토글하는 유스케이스 계약입니다.
public protocol ToggleTodoCompletionUseCase {
    func execute(id: Int)
}

// TODO를 삭제하는 유스케이스 계약입니다.
public protocol DeleteTodoUseCase {
    func execute(id: Int)
}

// TODO 순서를 변경하는 유스케이스 계약입니다.
public protocol MoveTodoUseCase {
    func execute(fromOffsets: IndexSet, toOffset: Int)
}

// 마지막 삭제를 복구하는 유스케이스 계약입니다.
public protocol UndoTodoDeletionUseCase {
    func execute()
}

// Undo 토스트 상태를 비우는 유스케이스 계약입니다.
public protocol ClearUndoToastUseCase {
    func execute()
}

// 앱의 TODO 데이터를 전체 삭제하는 유스케이스 계약입니다.
public protocol ClearAllTodosUseCase {
    func execute()
}

// TODO 화면 상태 조회 유스케이스 계약입니다.
public protocol ReadTodoScreenStateUseCase {
    func readUndoToast() -> UndoToastState?
}

// 전체 TODO 순서를 ID 기준으로 재정렬하는 유스케이스 계약입니다.
public protocol ReorderTodoListUseCase {
    func execute(orderedIDs: [Int])
}
