import Foundation

/// 서비스 기반 목록 조회 유스케이스 구현입니다.
public struct DefaultFetchTodoListUseCase: FetchTodoListUseCase {
    private let service: TodoServiceType

    /// 목록 조회 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// TODO 목록을 조회합니다.
    /// - Returns: 현재 TODO 전체 목록입니다.
    public func execute() -> [TodoItemViewData] {
        service.items
    }
}
