import SwiftUI

/// Todo 화면 공통 `View` 확장입니다.
extension View {
    /// Todo 공통 카드 스타일을 적용합니다.
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

    /// iOS 16.1+/macOS 13+에서만 rounded font design을 적용합니다.
    @ViewBuilder
    func todoRoundedFontDesign() -> some View {
        if #available(iOS 16.1, macOS 13.0, *) {
            self.fontDesign(.rounded)
        } else {
            self
        }
    }

    /// iOS에서는 네비게이션 바 타이틀 표시 모드를 inline으로 고정합니다.
    @ViewBuilder
    func todoNavigationBarInline() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// iOS에서만 편집 모드를 제어해 정렬 모드일 때만 기본 핸들을 노출합니다.
    @ViewBuilder
    func todoEditMode(active: Bool) -> some View {
        #if os(iOS)
        self.environment(\.editMode, .constant(active ? .active : .inactive))
        #else
        self
        #endif
    }

    /// iOS 전용 입력 관련 modifier를 조건부로 적용합니다.
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
