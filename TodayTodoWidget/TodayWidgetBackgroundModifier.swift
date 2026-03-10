import SwiftUI

/// iOS 16/17 배경 API 차이를 흡수하는 위젯 배경 modifier입니다.
struct TodayWidgetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content
                .padding(12)
                .containerBackground(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.98, blue: 1.0), Color(red: 0.9, green: 0.95, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    for: .widget
                )
        } else {
            content
                .padding(12)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.98, blue: 1.0), Color(red: 0.9, green: 0.95, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}
