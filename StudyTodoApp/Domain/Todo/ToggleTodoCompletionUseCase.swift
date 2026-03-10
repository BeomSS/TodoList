import Foundation

/// TODO 완료 상태를 토글하는 유스케이스 계약입니다.
public protocol ToggleTodoCompletionUseCase {
    /// TODO 완료 상태를 토글합니다.
    /// - Parameter id: 토글 대상 TODO ID입니다.
    func execute(id: Int)
}
