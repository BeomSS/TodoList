import Foundation

/// 위젯 목록 행 모델입니다.
struct TodayTodoEntryItem: Identifiable {
    /// 할 일 고유 ID입니다.
    let id: Int
    /// 할 일 제목입니다.
    let title: String
    /// 마감 시각입니다.
    let endDate: Date
}
