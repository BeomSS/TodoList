import SwiftUI

/// 버튼 탭 시 iOS 기본 컴포넌트와 유사한 미세 축소/투명도 반응을 제공합니다.
struct TodoPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
