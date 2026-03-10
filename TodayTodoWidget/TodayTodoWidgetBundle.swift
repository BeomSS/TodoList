import WidgetKit
import SwiftUI

/// 위젯 번들 진입점입니다.
@main
struct TodayTodoWidgetBundle: WidgetBundle {
    /// 번들에 포함된 위젯 목록입니다.
    var body: some Widget {
        TodayTodoWidget()
    }
}
