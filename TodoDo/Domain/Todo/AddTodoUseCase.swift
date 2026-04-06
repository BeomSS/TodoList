import Foundation

/// TODO를 추가하는 유스케이스 계약입니다.
public protocol AddTodoUseCase {
    /// TODO를 추가합니다.
    /// - Parameters:
    ///   - title: 할 일 제목입니다.
    ///   - endDate: 마감 시각입니다.
    ///   - reminderOffsets: 알림 오프셋(초) 목록입니다.
    func execute(title: String, endDate: Date?, reminderOffsets: [Int])
}
