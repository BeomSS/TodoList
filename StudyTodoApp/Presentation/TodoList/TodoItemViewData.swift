import Foundation

// 화면에 표시할 TODO 데이터입니다.
public struct TodoItemViewData: Identifiable, Equatable, Codable {
    // 항목 고유 ID입니다.
    public let id: Int
    // 할 일 제목입니다.
    public let title: String
    // 목표 완료(마감) 일시입니다. 지정하지 않으면 nil입니다.
    public let endDate: Date?
    // 완료 여부입니다.
    public let isCompleted: Bool
    // 완료된 시각입니다. 완료되지 않았으면 nil입니다.
    public let completedAt: Date?

    public init(
        id: Int,
        title: String,
        endDate: Date? = nil,
        isCompleted: Bool,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}
