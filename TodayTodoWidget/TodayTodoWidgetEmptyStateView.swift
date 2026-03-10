import SwiftUI

/// 위젯 빈 상태 메시지입니다.
struct TodayTodoWidgetEmptyStateView: View {
    /// 빈 상태 본문입니다.
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘 마감 일정이 없습니다")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("새 할 일을 추가해보세요")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary.opacity(0.85))
        }
    }
}
