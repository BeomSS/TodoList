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
        VStack(alignment: .leading, spacing: containerSpacing) {
            TodayTodoWidgetHeaderView()

            if entry.items.isEmpty {
                TodayTodoWidgetEmptyStateView()
            } else {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(visibleItems) { item in
                        TodayTodoWidgetItemRowView(
                            item: item,
                            titleFont: titleFont,
                            titleLineLimit: titleLineLimit,
                            subtitleFont: subtitleFont
                        )
                    }
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

    /// 위젯 전체 수직 간격입니다.
    private var containerSpacing: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 10
        default:
            return 8
        }
    }

    /// 항목 행 사이 간격입니다.
    private var rowSpacing: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 8
        default:
            return 6
        }
    }

    /// 제목 폰트입니다. 중간 위젯에서는 더 작은 폰트를 사용해 더 많은 글자를 노출합니다.
    private var titleFont: Font {
        switch widgetFamily {
        case .systemSmall:
            return .subheadline.weight(.semibold)
        default:
            return .footnote.weight(.semibold)
        }
    }

    /// 제목 최대 줄 수입니다.
    private var titleLineLimit: Int {
        switch widgetFamily {
        case .systemSmall:
            return 2
        case .systemMedium:
            return 1
        default:
            return 2
        }
    }

    /// 부제목(마감 시각) 폰트입니다.
    private var subtitleFont: Font {
        switch widgetFamily {
        case .systemSmall:
            return .caption2.weight(.medium)
        default:
            return .caption2
        }
    }
}
