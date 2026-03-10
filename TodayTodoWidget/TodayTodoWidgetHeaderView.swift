import SwiftUI

/// 위젯 상단 타이틀 헤더입니다.
struct TodayTodoWidgetHeaderView: View {
    /// 헤더 본문입니다.
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("오늘")
                .font(.headline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(1.0)

            Spacer()
        }
    }
}
