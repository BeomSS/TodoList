import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Todo 화면군에서 공통으로 쓰는 색상/배경 스타일 모음입니다.
enum TodoTheme {
    /// 화면 전반 배경 그라데이션입니다.
    static let backgroundGradient = LinearGradient(
        colors: [Color(red: 0.96, green: 0.98, blue: 1.0), Color(red: 0.9, green: 0.94, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 카드 베이스 배경입니다.
    static let cardFill = Color.white.opacity(0.86)
    /// 카드 외곽선 색상입니다.
    static let cardStroke = Color.white.opacity(0.72)
    /// 카드 모서리 반경입니다.
    static let cardCornerRadius: CGFloat = 18

    /// 팝업 취소 버튼 배경 색상입니다.
    static var popupCancelBackgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .systemGray5)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }

    /// 팝업 입력창 배경 색상입니다.
    static var popupInputBackgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .systemGray6)
        #else
        return Color.gray.opacity(0.14)
        #endif
    }
}
