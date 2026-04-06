import Foundation

/// 서비스 기반 화면 상태 조회 유스케이스 구현입니다.
public struct DefaultReadTodoScreenStateUseCase: ReadTodoScreenStateUseCase {
    private let service: TodoServiceType

    /// 화면 상태 조회 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// 현재 Undo 토스트 상태를 반환합니다.
    /// - Returns: Undo 토스트 상태입니다.
    public func readUndoToast() -> UndoToastState? {
        service.undoToast
    }
}
