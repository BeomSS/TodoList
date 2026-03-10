import Foundation

/// 앱/위젯 공용 스냅샷 항목 모델입니다.
public struct SharedTodayTodoWidgetItem: Codable, Identifiable {
    /// 할 일 고유 ID입니다.
    public let id: Int
    /// 할 일 제목입니다.
    public let title: String
    /// 마감 시각입니다.
    public let endDate: Date

    /// 위젯 항목 모델을 생성합니다.
    /// - Parameters:
    ///   - id: 항목 고유 ID입니다.
    ///   - title: 항목 제목입니다.
    ///   - endDate: 항목 마감 시각입니다.
    public init(id: Int, title: String, endDate: Date) {
        self.id = id
        self.title = title
        self.endDate = endDate
    }
}
