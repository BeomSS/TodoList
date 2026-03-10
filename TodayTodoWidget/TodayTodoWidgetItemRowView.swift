import SwiftUI

/// 위젯 단일 할 일 행입니다.
struct TodayTodoWidgetItemRowView: View {
    /// 표시할 항목입니다.
    let item: TodayTodoEntryItem

    /// 단일 행 본문입니다.
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(urgencyColor(for: item.endDate))
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text("마감 \(item.endDate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    /// 마감 임박 정도에 따라 점 색상을 다르게 표시합니다.
    /// - Parameter endDate: 항목 마감 시각입니다.
    /// - Returns: 마감 상태를 표현하는 색상입니다.
    private func urgencyColor(for endDate: Date) -> Color {
        let remaining = endDate.timeIntervalSinceNow
        if remaining <= 60 * 60 {
            return .red
        } else if remaining <= 3 * 60 * 60 {
            return .orange
        } else {
            return .blue
        }
    }
}
