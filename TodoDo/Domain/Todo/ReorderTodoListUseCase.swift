import Foundation

/// 전체 TODO 순서를 ID 기준으로 재정렬하는 유스케이스 계약입니다.
public protocol ReorderTodoListUseCase {
    /// ID 기준으로 TODO 전체 순서를 재정렬합니다.
    /// - Parameter orderedIDs: 최종 순서대로 정렬된 TODO ID 목록입니다.
    func execute(orderedIDs: [Int])
}
