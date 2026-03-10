import Foundation

/// 앱/위젯 공용 스냅샷 모델입니다.
/// App Group UserDefaults에 JSON으로 저장/복원됩니다.
public struct SharedTodayTodoWidgetSnapshot: Codable {
    /// 스냅샷 생성 시각입니다.
    public let updatedAt: Date
    /// 오늘 마감 진행중 할 일 총 개수입니다.
    public let todayCount: Int
    /// 위젯 목록에 표시할 항목들입니다.
    public let items: [SharedTodayTodoWidgetItem]

    /// 위젯 스냅샷을 생성합니다.
    /// - Parameters:
    ///   - updatedAt: 스냅샷 생성 시각입니다.
    ///   - todayCount: 오늘 마감 진행중 할 일 총 개수입니다.
    ///   - items: 위젯에 표시할 항목 목록입니다.
    public init(updatedAt: Date, todayCount: Int, items: [SharedTodayTodoWidgetItem]) {
        self.updatedAt = updatedAt
        self.todayCount = todayCount
        self.items = items
    }
}
