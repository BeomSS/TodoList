import SwiftUI
import WidgetKit

/// 위젯 정의입니다.
struct TodayTodoWidget: Widget {
    /// 위젯 시스템 식별자입니다.
    let kind: String = TodayTodoWidgetConfig.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayTodoProvider()) { entry in
            TodayTodoWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘 할 일")
        .description("오늘 마감 예정인 할 일을 빠르게 확인합니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
