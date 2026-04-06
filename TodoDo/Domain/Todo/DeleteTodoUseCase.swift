import Foundation

/// TODO를 삭제하는 유스케이스 계약입니다.
public protocol DeleteTodoUseCase {
    /// TODO를 삭제합니다.
    /// - Parameter id: 삭제 대상 TODO ID입니다.
    func execute(id: Int)
}
