import Foundation

/// TODO 알림 권한 상태 조회 계약입니다.
public protocol TodoReminderPermissionChecking {
    /// 현재 앱의 로컬 알림 권한 상태를 반환합니다.
    /// - Returns: 알림 사용 가능/미결정/거부 상태입니다.
    @MainActor
    func currentStatus() async -> TodoReminderPermissionStatus
}
