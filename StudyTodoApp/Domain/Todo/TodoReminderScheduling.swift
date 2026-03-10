import Foundation

/// TODO 항목 마감 알림(로컬 푸시) 스케줄링 계약입니다.
/// Domain/Service 계층은 이 프로토콜에만 의존하며, 실제 구현은 Data 계층에서 담당합니다.
public protocol TodoReminderScheduling {
    /// 특정 TODO의 알림을 현재 상태로 교체합니다.
    /// 내부적으로 기존 알림을 제거한 뒤 필요한 알림만 다시 등록합니다.
    /// - Parameter item: 현재 상태를 기준으로 알림을 등록할 TODO 항목입니다.
    func replaceReminders(for item: TodoItemViewData)

    /// 특정 TODO의 예약 알림만 제거합니다.
    /// - Parameter id: 제거 대상 TODO ID입니다.
    func removeReminders(forTodoID id: Int)

    /// 앱의 TODO 예약 알림을 전체 제거합니다.
    func removeAllReminders()
}
