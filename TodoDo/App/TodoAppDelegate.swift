import Foundation
import UIKit
import UserNotifications

/// 로컬 푸시 탭 이벤트를 SwiftUI 계층으로 전달하는 앱 델리게이트입니다.
final class TodoAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    /// 알림 델리게이트를 등록하고 앱 초기화를 완료합니다.
    /// - Parameters:
    ///   - application: 현재 앱 인스턴스입니다.
    ///   - launchOptions: 앱 실행 옵션입니다.
    /// - Returns: 앱 초기화 성공 여부입니다.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 포그라운드/백그라운드 알림 응답을 받기 위해 delegate를 설정합니다.
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// 사용자가 알림을 탭했을 때 해당 TODO ID를 선택 센터로 전달합니다.
    /// - Parameters:
    ///   - center: 알림 센터 인스턴스입니다.
    ///   - response: 사용자 응답 정보입니다.
    ///   - completionHandler: 시스템에게 처리 완료를 알리는 콜백입니다.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 알림 payload의 todoID를 꺼내 화면 선택 센터에 전달합니다.
        let todoID = response.notification.request.content.userInfo["todoID"] as? Int
        if let todoID {
            Task { @MainActor in
                TodoNotificationSelectionCenter.shared.select(todoID: todoID)
            }
        }
        completionHandler()
    }
}
