import Foundation

/// TODO 화면 상태 조회 유스케이스 계약입니다.
public protocol ReadTodoScreenStateUseCase {
    /// 현재 Undo 토스트 상태를 읽어옵니다.
    /// - Returns: 현재 Undo 토스트 상태입니다.
    func readUndoToast() -> UndoToastState?
}
