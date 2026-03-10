import Foundation

/// Undo 토스트 상태를 비우는 유스케이스 계약입니다.
public protocol ClearUndoToastUseCase {
    /// Undo 토스트 상태를 초기화합니다.
    func execute()
}
