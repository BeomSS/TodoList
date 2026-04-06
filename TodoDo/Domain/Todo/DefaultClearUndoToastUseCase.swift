import Foundation

/// 서비스 기반 Undo 토스트 비움 유스케이스 구현입니다.
public struct DefaultClearUndoToastUseCase: ClearUndoToastUseCase {
    private let service: TodoServiceType

    /// Undo 토스트 비움 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// Undo 토스트 상태를 초기화합니다.
    public func execute() {
        service.clearUndoToast()
    }
}
