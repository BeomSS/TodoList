import Foundation

/// 서비스 기반 완료 토글 유스케이스 구현입니다.
public struct DefaultToggleTodoCompletionUseCase: ToggleTodoCompletionUseCase {
    private let service: TodoServiceType

    /// 완료 토글 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// TODO 완료 상태를 토글합니다.
    /// - Parameter id: 토글 대상 TODO ID입니다.
    public func execute(id: Int) {
        service.toggleCompletion(id: id)
    }
}
