import Foundation

/// TODO 목록 분리 전략 계약입니다.
/// 화면별 필터/정렬 요구사항이 바뀌어도 ViewModel 수정 범위를 최소화할 수 있습니다.
public protocol TodoListPartitioning {
    /// 전체 목록을 진행중/완료 목록으로 분리합니다.
    /// - Parameter items: 전체 TODO 목록입니다.
    /// - Returns: 화면 바인딩에 사용할 분리 결과입니다.
    func partition(items: [TodoItemViewData]) -> TodoListPartition
}
