import Foundation

/// 테스트/프리뷰에서 사용하는 no-op 권한 조회 구현입니다.
public struct NoOpTodoReminderPermissionChecker: TodoReminderPermissionChecking {
    public init() {}

    @MainActor
    public func currentStatus() async -> TodoReminderPermissionStatus {
        .authorized
    }
}
