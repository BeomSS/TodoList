import Foundation

/// 서비스 기반 TODO 추가 유스케이스 구현입니다.
public struct DefaultAddTodoUseCase: AddTodoUseCase {
    private let service: TodoServiceType

    /// 추가 유스케이스를 생성합니다.
    /// - Parameter service: TODO 서비스 구현체입니다.
    public init(service: TodoServiceType) {
        self.service = service
    }

    /// TODO를 추가합니다.
    /// - Parameters:
    ///   - title: 할 일 제목입니다.
    ///   - endDate: 마감 시각입니다.
    ///   - reminderOffsets: 알림 오프셋(초) 목록입니다.
    public func execute(title: String, endDate: Date?, reminderOffsets: [Int]) {
        service.addTodo(title: title, endDate: endDate, reminderOffsets: reminderOffsets)
    }
}
