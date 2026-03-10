import Foundation

/// TODO 도메인 이벤트 모델입니다.
/// 분석/동기화/로그 수집 등 후속 확장 포인트로 사용합니다.
public struct TodoEvent: Sendable {
    /// 이벤트 종류입니다.
    public let kind: TodoEventKind
    /// 이벤트 대상 TODO ID입니다. 전체 작업 이벤트는 `nil`일 수 있습니다.
    public let todoID: Int?
    /// 이벤트 발생 시각입니다.
    public let occurredAt: Date

    /// 도메인 이벤트를 생성합니다.
    /// - Parameters:
    ///   - kind: 이벤트 종류입니다.
    ///   - todoID: 대상 TODO ID입니다.
    ///   - occurredAt: 이벤트 발생 시각입니다.
    public init(kind: TodoEventKind, todoID: Int?, occurredAt: Date) {
        self.kind = kind
        self.todoID = todoID
        self.occurredAt = occurredAt
    }
}
