import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 앱 전반의 햅틱 출력을 일관된 강도로 통합합니다.
enum TodoHaptics {
    /// 선택 변경 피드백을 출력합니다.
    static func selection() {
        #if os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    /// 성공 피드백을 출력합니다.
    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    /// 경고 피드백을 출력합니다.
    static func warning() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }

    /// 가벼운 임팩트 피드백을 출력합니다.
    static func lightImpact() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
