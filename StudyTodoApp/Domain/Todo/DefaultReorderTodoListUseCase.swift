import Foundation

/// 서비스 기반 전체 순서 재정렬 유스케이스 구현입니다.
public struct DefaultReorderTodoListUseCase: ReorderTodoListUseCase {
    private let service: TodoServiceType

    /// 전체 순서 재정렬 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// ID 기준으로 TODO 전체 순서를 재배치합니다.
    /// - Parameter orderedIDs: 최종 순서대로 정렬된 TODO ID 목록입니다.
    public func execute(orderedIDs: [Int]) {
        service.reorderTodos(orderedIDs: orderedIDs)
    }
}
