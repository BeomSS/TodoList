import Foundation

/// 현재 TODO 목록을 조회하는 유스케이스 계약입니다.
public protocol FetchTodoListUseCase {
    /// TODO 전체 목록을 조회합니다.
    /// - Returns: 현재 상태의 TODO 목록입니다.
    func execute() -> [TodoItemViewData]
}
