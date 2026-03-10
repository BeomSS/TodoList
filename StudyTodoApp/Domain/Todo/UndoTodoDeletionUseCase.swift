import Foundation

/// 마지막 삭제를 복구하는 유스케이스 계약입니다.
public protocol UndoTodoDeletionUseCase {
    /// 마지막 삭제를 복구합니다.
    func execute()
}
