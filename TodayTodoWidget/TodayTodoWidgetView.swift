import SwiftUI
import WidgetKit

/// 실제 위젯 View입니다.
struct TodayTodoWidgetView: View {
    /// 현재 위젯 패밀리(small/medium)입니다.
    @Environment(\.widgetFamily) private var widgetFamily
    /// 시스템이 전달한 현재 엔트리입니다.
    let entry: TodayTodoEntry

    /// 위젯 본문입니다.
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TodayTodoWidgetHeaderView()

            if entry.items.isEmpty {
                TodayTodoWidgetEmptyStateView()
            } else {
                ForEach(visibleItems) { item in
                    TodayTodoWidgetItemRowView(item: item)
                }

                if hiddenItemCount > 0 {
                    Text("… 외 \(hiddenItemCount)건")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .modifier(TodayWidgetBackgroundModifier())
    }

    /// 위젯 패밀리 정책에 맞춰 실제 노출할 항목입니다.
    private var visibleItems: [TodayTodoEntryItem] {
        Array(entry.items.prefix(maxVisibleItemCount))
    }

    /// 노출되지 않은 나머지 오늘 항목 개수입니다.
    private var hiddenItemCount: Int {
        max(entry.todayCount - visibleItems.count, 0)
    }

    /// 패밀리별 최대 노출 개수입니다.
    private var maxVisibleItemCount: Int {
        switch widgetFamily {
        case .systemSmall:
            return 1
        default:
            return 2
        }
    }
}
