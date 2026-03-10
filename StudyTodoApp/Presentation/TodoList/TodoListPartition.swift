import Foundation

/// TODO 목록을 화면 목적에 맞게 분리한 결과입니다.
public struct TodoListPartition {
    /// 진행중 항목 목록입니다.
    public let inProgress: [TodoItemViewData]
    /// 완료 항목 목록입니다.
    public let completed: [TodoItemViewData]

    /// 분리 결과를 생성합니다.
    /// - Parameters:
    ///   - inProgress: 진행중 항목 목록입니다.
    ///   - completed: 완료 항목 목록입니다.
    public init(inProgress: [TodoItemViewData], completed: [TodoItemViewData]) {
        self.inProgress = inProgress
        self.completed = completed
    }
}
