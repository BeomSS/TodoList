import Foundation

#if canImport(UserNotifications)
import UserNotifications
#endif

/// iOS 로컬 알림 권한 상태를 조회하는 구현체입니다.
public struct LocalNotificationPermissionChecker: TodoReminderPermissionChecking {
    public init() {}

    /// 현재 로컬 알림 권한 상태를 조회합니다.
    /// - Returns: 도메인 레벨 권한 상태(`authorized`/`notDetermined`/`denied`)입니다.
    @MainActor
    public func currentStatus() async -> TodoReminderPermissionStatus {
        #if canImport(UserNotifications)
        // 시스템 알림 센터의 현재 권한 상태를 조회합니다.
        let center = UNUserNotificationCenter.current()

        return await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                let status: TodoReminderPermissionStatus

                // 시스템 상태를 앱 도메인 상태로 매핑합니다.
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    status = .authorized
                case .notDetermined:
                    status = .notDetermined
                case .denied:
                    status = .denied
                @unknown default:
                    status = .denied
                }

                // 비동기 콜백 결과를 async 반환값으로 전달합니다.
                continuation.resume(returning: status)
            }
        }
        #else
        // UserNotifications를 지원하지 않는 플랫폼에서는 권한 제한을 두지 않습니다.
        return .authorized
        #endif
    }
}
