import Foundation

/// 앱의 TODO 데이터를 전체 삭제하는 유스케이스 계약입니다.
public protocol ClearAllTodosUseCase {
    /// 모든 TODO 데이터를 삭제합니다.
    func execute()
}
