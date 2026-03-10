import Foundation

/// 서비스 기반 TODO 수정 유스케이스 구현입니다.
public struct DefaultUpdateTodoUseCase: UpdateTodoUseCase {
    private let service: TodoServiceType

    /// 수정 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// TODO를 수정합니다.
    /// - Parameters:
    ///   - id: 수정 대상 TODO ID입니다.
    ///   - title: 변경할 제목입니다.
    ///   - endDate: 변경할 마감 시각입니다.
    ///   - reminderOffsets: 변경할 알림 오프셋(초) 목록입니다.
    public func execute(id: Int, title: String, endDate: Date?, reminderOffsets: [Int]) {
        service.updateTodo(id: id, title: title, endDate: endDate, reminderOffsets: reminderOffsets)
    }
}
