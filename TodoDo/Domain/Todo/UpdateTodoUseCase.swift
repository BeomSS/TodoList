import Foundation

/// TODO 제목/마감일/알림을 수정하는 유스케이스 계약입니다.
public protocol UpdateTodoUseCase {
    /// TODO를 수정합니다.
    /// - Parameters:
    ///   - id: 수정 대상 TODO ID입니다.
    ///   - title: 변경할 제목입니다.
    ///   - endDate: 변경할 마감 시각입니다.
    ///   - reminderOffsets: 변경할 알림 오프셋(초) 목록입니다.
    func execute(id: Int, title: String, endDate: Date?, reminderOffsets: [Int])
}
