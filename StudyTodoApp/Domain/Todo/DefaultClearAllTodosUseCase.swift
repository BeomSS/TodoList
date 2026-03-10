import Foundation

/// 서비스 기반 전체 데이터 삭제 유스케이스 구현입니다.
public struct DefaultClearAllTodosUseCase: ClearAllTodosUseCase {
    private let service: TodoServiceType

    /// 전체 데이터 삭제 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// TODO 데이터를 전체 삭제합니다.
    public func execute() {
        service.clearAllTodos()
    }
}
