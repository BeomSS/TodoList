import Foundation

/// 아무 작업도 하지 않는 기본 이벤트 발행기입니다.
public struct NoOpTodoEventPublisher: TodoEventPublishing {
    /// no-op 이벤트 발행기를 생성합니다.
    public init() {}

    /// 이벤트를 무시합니다.
    /// - Parameter event: 발행 요청 이벤트입니다.
    public func publish(_ event: TodoEvent) {}
}
