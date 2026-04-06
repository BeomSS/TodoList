import Foundation

/// 오늘 TODO 위젯에서 공통으로 사용하는 설정 상수입니다.
public enum TodayTodoWidgetConfig {
    /// WidgetKit 식별자(kind)입니다.
    public static let kind = "TodayTodoWidget"
    /// 앱에서 저장할 최대 항목 수입니다.
    /// 실제 표시 개수는 위젯 패밀리 정책(small 1 / medium 2)로 별도 제한됩니다.
    public static let maxStoredItemCount = 6
}
