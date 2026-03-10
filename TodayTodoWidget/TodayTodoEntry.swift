import Foundation
import WidgetKit

/// 위젯 타임라인 엔트리입니다.
/// 엔트리 1개에는 위젯 렌더링에 필요한 오늘 할 일 스냅샷이 담깁니다.
struct TodayTodoEntry: TimelineEntry {
    /// 위젯 갱신 시점입니다.
    let date: Date
    /// 위젯 제목에 표시할 오늘 할 일 개수입니다.
    let todayCount: Int
    /// 위젯 본문 목록입니다.
    let items: [TodayTodoEntryItem]
}
