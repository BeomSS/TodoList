import Foundation

/// 기본 TODO 목록 분리 전략입니다.
public struct DefaultTodoListPartitioner: TodoListPartitioning {
    /// 기본 분리 전략을 생성합니다.
    public init() {}

    /// `isCompleted` 기준으로 목록을 분리합니다.
    /// - Parameter items: 전체 TODO 목록입니다.
    /// - Returns: 진행중/완료 목록 분리 결과입니다.
    public func partition(items: [TodoItemViewData]) -> TodoListPartition {
        TodoListPartition(
            inProgress: items.filter { $0.isCompleted == false },
            completed: items.filter(\.isCompleted)
        )
    }
}
