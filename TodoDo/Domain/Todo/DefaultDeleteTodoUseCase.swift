import Foundation

/// 서비스 기반 TODO 삭제 유스케이스 구현입니다.
public struct DefaultDeleteTodoUseCase: DeleteTodoUseCase {
    private let service: TodoServiceType

    /// 삭제 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// TODO를 삭제합니다.
    /// - Parameter id: 삭제 대상 TODO ID입니다.
    public func execute(id: Int) {
        service.deleteTodo(id: id)
    }
}
