import Foundation

/// 화면에 표시할 TODO 데이터 모델입니다.
public struct TodoItemViewData: Identifiable, Equatable, Codable {
    // 항목 고유 ID입니다.
    public let id: Int
    // 할 일 제목입니다.
    public let title: String
    // 목표 완료(마감) 일시입니다. 지정하지 않으면 nil입니다.
    public let endDate: Date?
    // 마감 전에 받을 알림 오프셋(초) 목록입니다. 예: 300(5분 전), 3600(1시간 전)
    public let reminderOffsets: [Int]
    // 완료 여부입니다.
    public let isCompleted: Bool
    // 완료된 시각입니다. 완료되지 않았으면 nil입니다.
    public let completedAt: Date?

    /// TODO 표시 모델을 생성합니다.
    /// - Parameters:
    ///   - id: 항목 고유 ID입니다.
    ///   - title: 할 일 제목입니다.
    ///   - endDate: 목표 완료(마감) 시각입니다.
    ///   - reminderOffsets: 마감 기준 알림 오프셋(초) 목록입니다.
    ///   - isCompleted: 완료 여부입니다.
    ///   - completedAt: 완료 시각입니다.
    public init(
        id: Int,
        title: String,
        endDate: Date? = nil,
        reminderOffsets: [Int] = [],
        isCompleted: Bool,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.endDate = endDate
        self.reminderOffsets = reminderOffsets
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}
