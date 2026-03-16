import Foundation

/// `AppStorage`에서 공통으로 사용하는 키 모음입니다.
enum TodoAppStorageKey {
    /// 완료 화면 되돌리기 확인 팝업 생략 여부 키입니다.
    static let restoreAlwaysAllow = "todo_restore_always_allow"
    /// Siri로 할 일 추가 가이드 1회 노출 여부 키입니다.
    static let hasShownSiriAddGuide = "todo_has_shown_siri_add_guide"
    /// 1회성 가이드/팁 노출 여부 키 목록입니다.
    /// 앱 데이터 전체 삭제 시 이 목록을 순회해 재노출 가능 상태로 초기화합니다.
    static let oneTimeGuideKeys = [
        hasShownSiriAddGuide
    ]
}
