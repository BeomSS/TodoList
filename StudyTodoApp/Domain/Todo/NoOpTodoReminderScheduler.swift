import Foundation

/// 테스트/프리뷰/비지원 플랫폼에서 사용하는 no-op 스케줄러입니다.
public struct NoOpTodoReminderScheduler: TodoReminderScheduling {
    public init() {}

    public func replaceReminders(for item: TodoItemViewData) {}

    public func removeReminders(forTodoID id: Int) {}

    public func removeAllReminders() {}
}
