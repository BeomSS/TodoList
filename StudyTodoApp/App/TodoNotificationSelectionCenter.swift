import Foundation

/// 알림 탭으로 전달된 TODO ID를 화면 계층으로 전달하는 공유 선택 센터입니다.
@MainActor
public final class TodoNotificationSelectionCenter: ObservableObject {
    // 앱 전체에서 같은 인스턴스를 사용합니다.
    public static let shared = TodoNotificationSelectionCenter()

    // 화면에서 소비할 현재 선택 TODO ID입니다.
    @Published public private(set) var selectedTodoID: Int?

    private init() {}

    /// 알림 탭으로 들어온 TODO ID를 등록합니다.
    /// - Parameter todoID: 강조/스크롤 대상으로 전달할 TODO ID입니다.
    public func select(todoID: Int) {
        selectedTodoID = todoID
    }

    /// 화면이 선택 이벤트를 소비한 뒤 선택 상태를 비웁니다.
    public func clearSelection() {
        selectedTodoID = nil
    }
}
