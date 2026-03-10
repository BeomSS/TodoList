import Foundation

/// 서비스 기반 삭제 복구 유스케이스 구현입니다.
public struct DefaultUndoTodoDeletionUseCase: UndoTodoDeletionUseCase {
    private let service: TodoServiceType

    /// 삭제 복구 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// 마지막 삭제를 복구합니다.
    public func execute() {
        service.undoLastDeletion()
    }
}
