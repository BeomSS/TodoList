import Foundation
import UserNotifications

/// iOS 로컬 푸시 기반 TODO 마감 알림 스케줄러 구현입니다.
/// 알림 식별자를 `TODO ID + 오프셋(초)`로 구성해 항목별 추가/수정/삭제 시 정확히 갱신합니다.
public struct LocalNotificationTodoReminderScheduler: TodoReminderScheduling {
    // 알림 식별자 prefix입니다. 앱 내 다른 알림과 충돌을 피하기 위해 네임스페이스를 고정합니다.
    private let identifierPrefix = "todo.reminder"

    public init() {}

    /// 특정 TODO의 예약 알림을 현재 상태로 재등록합니다.
    /// - Parameter item: 알림 등록 기준이 되는 TODO 항목입니다.
    public func replaceReminders(for item: TodoItemViewData) {
        // 동일 TODO에 걸린 기존 알림을 먼저 제거한 뒤 현재 상태로 다시 등록합니다.
        removeReminders(forTodoID: item.id)

        // 완료 항목/마감일 미지정 항목/알림 선택 없음은 푸시를 만들지 않습니다.
        guard item.isCompleted == false else { return }
        guard let endDate = item.endDate else { return }
        guard item.reminderOffsets.isEmpty == false else { return }

        let center = UNUserNotificationCenter.current()
        let prefix = identifierPrefix

        // 최초 1회 권한 요청을 시도합니다.
        // 이미 권한 상태가 결정된 경우에는 즉시 등록 로직으로 분기합니다.
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                Self.scheduleRequests(center: center, item: item, endDate: endDate, prefix: prefix)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    Self.scheduleRequests(center: center, item: item, endDate: endDate, prefix: prefix)
                }
            case .denied:
                return
            @unknown default:
                return
            }
        }
    }

    /// 특정 TODO ID에 연결된 예약 알림을 제거합니다.
    /// - Parameter id: 제거 대상 TODO ID입니다.
    public func removeReminders(forTodoID id: Int) {
        let center = UNUserNotificationCenter.current()
        let targetPrefix = "\(identifierPrefix).\(id)."

        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(targetPrefix) }

            guard identifiers.isEmpty == false else { return }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    /// 이 앱이 등록한 TODO 예약 알림을 전체 제거합니다.
    public func removeAllReminders() {
        let center = UNUserNotificationCenter.current()
        let targetPrefix = "\(identifierPrefix)."

        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(targetPrefix) }

            guard identifiers.isEmpty == false else { return }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    // TODO ID/알림 오프셋 조합으로 고유 알림 ID를 만듭니다.
    private static func notificationIdentifier(prefix: String, todoID: Int, offset: Int) -> String {
        "\(prefix).\(todoID).\(offset)"
    }

    // 실제 알림 요청 생성/등록을 수행합니다.
    private static func scheduleRequests(
        center: UNUserNotificationCenter,
        item: TodoItemViewData,
        endDate: Date,
        prefix: String
    ) {
        // 과거 시점 트리거는 제외하고, 미래 시점만 예약합니다.
        for offset in item.reminderOffsets {
            let triggerDate = endDate.addingTimeInterval(TimeInterval(-offset))
            guard triggerDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Todo 알림"
            content.body = "\(item.title) 마감이 다가옵니다."
            content.sound = .default
            // 알림 탭 시 해당 TODO를 식별할 수 있도록 userInfo에 ID를 포함합니다.
            content.userInfo = ["todoID": item.id]

            // 캘린더 기준 절대 시각 트리거를 사용해 앱 재시작 후에도 알림을 유지합니다.
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: triggerDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(prefix: prefix, todoID: item.id, offset: offset),
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }
}
