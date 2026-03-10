import Foundation

/// TODO 순서를 변경하는 유스케이스 계약입니다.
public protocol MoveTodoUseCase {
    /// 목록 순서를 이동합니다.
    /// - Parameters:
    ///   - fromOffsets: 원본 인덱스 집합입니다.
    ///   - toOffset: 이동 목적지 인덱스입니다.
    func execute(fromOffsets: IndexSet, toOffset: Int)
}
