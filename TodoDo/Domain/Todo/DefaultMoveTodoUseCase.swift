import Foundation

/// 서비스 기반 순서 변경 유스케이스 구현입니다.
public struct DefaultMoveTodoUseCase: MoveTodoUseCase {
    private let service: TodoServiceType

    /// 순서 변경 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// 목록 순서를 이동합니다.
    /// - Parameters:
    ///   - fromOffsets: 원본 인덱스 집합입니다.
    ///   - toOffset: 이동 목적지 인덱스입니다.
    public func execute(fromOffsets: IndexSet, toOffset: Int) {
        service.moveTodos(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
