import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Todo 화면군에서 공통으로 쓰는 색상/배경 스타일 모음입니다.
enum TodoTheme {
    // 화면 전반 배경 그라데이션입니다.
    static let backgroundGradient = LinearGradient(
        colors: [Color(red: 0.96, green: 0.98, blue: 1.0), Color(red: 0.9, green: 0.94, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // 카드 베이스 배경입니다.
    static let cardFill = Color.white.opacity(0.86)
    // 카드 외곽선 색상입니다.
    static let cardStroke = Color.white.opacity(0.72)
    // 카드 모서리 반경입니다.
    static let cardCornerRadius: CGFloat = 18
    // 팝업 취소 버튼 배경 색상입니다.
    static var popupCancelBackgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .systemGray5)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }
    // 팝업 입력창 배경 색상입니다.
    static var popupInputBackgroundColor: Color {
        #if os(iOS)
        return Color(uiColor: .systemGray6)
        #else
        return Color.gray.opacity(0.14)
        #endif
    }
}

// AppStorage에서 공통으로 사용하는 키 모음입니다.
enum TodoAppStorageKey {
    // 완료 화면 되돌리기 확인 팝업 생략 여부 키입니다.
    static let restoreAlwaysAllow = "todo_restore_always_allow"
}

// 화면 날짜 표시에 사용하는 포맷터 모음입니다.
enum DateDisplay {
    static let todoDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 a h:mm"
        return formatter
    }()
}

// 앱 전반의 햅틱 출력을 일관된 강도로 통합합니다.
enum TodoHaptics {
    static func selection() {
        #if os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }

    static func lightImpact() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

// 버튼 탭 시 iOS 기본 컴포넌트와 유사한 미세 축소/투명도 반응을 제공합니다.
struct TodoPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    // Todo 공통 카드 스타일을 적용합니다.
    func todoCardStyle() -> some View {
        background(
            RoundedRectangle(cornerRadius: TodoTheme.cardCornerRadius, style: .continuous)
                .fill(TodoTheme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: TodoTheme.cardCornerRadius, style: .continuous)
                        .stroke(TodoTheme.cardStroke, lineWidth: 1)
                )
        )
    }

    // iOS 16.1+/macOS 13+에서만 rounded font design을 적용합니다.
    @ViewBuilder
    func todoRoundedFontDesign() -> some View {
        if #available(iOS 16.1, macOS 13.0, *) {
            self.fontDesign(.rounded)
        } else {
            self
        }
    }

    // iOS에서는 네비게이션 바 타이틀 표시 모드를 inline으로 고정합니다.
    @ViewBuilder
    func todoNavigationBarInline() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    // iOS에서만 편집 모드를 제어해 정렬 모드일 때만 기본 핸들을 노출합니다.
    @ViewBuilder
    func todoEditMode(active: Bool) -> some View {
        #if os(iOS)
        self.environment(\.editMode, .constant(active ? .active : .inactive))
        #else
        self
        #endif
    }

    // iOS 전용 입력 관련 modifier를 조건부로 적용합니다.
    @ViewBuilder
    func todoTextFieldInputStyle() -> some View {
        #if os(iOS)
        self
            .textInputAutocapitalization(.sentences)
            .submitLabel(.done)
        #else
        self
        #endif
    }
}
