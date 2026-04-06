import Foundation

/// TODO 알림 권한 상태입니다.
public enum TodoReminderPermissionStatus: Sendable {
    /// 알림 사용 가능 상태입니다.
    case authorized
    /// 아직 권한을 물어보지 않은 상태입니다.
    case notDetermined
    /// 사용자가 거부했거나 시스템 정책으로 비활성화된 상태입니다.
    case denied
}
