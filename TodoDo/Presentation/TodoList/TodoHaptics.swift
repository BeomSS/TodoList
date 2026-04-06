import Foundation
import UIKit

/// 앱 전반의 햅틱 출력을 일관된 강도로 통합합니다.
enum TodoHaptics {
    /// 선택 변경 피드백을 출력합니다.
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// 성공 피드백을 출력합니다.
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// 경고 피드백을 출력합니다.
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// 가벼운 임팩트 피드백을 출력합니다.
    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
