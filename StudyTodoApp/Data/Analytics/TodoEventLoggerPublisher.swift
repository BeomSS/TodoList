import Foundation
import OSLog

/// TODO 도메인 이벤트를 시스템 로그로 기록하는 기본 구현체입니다.
/// 추후 외부 분석 SDK 연동 전에도 운영 중 이벤트 흐름을 추적할 수 있습니다.
public struct TodoEventLoggerPublisher: TodoEventPublishing {
    /// 이벤트를 기록할 OSLog 로거입니다.
    private let logger: Logger
    /// 이벤트 시각 표시 포맷터입니다.
    private let dateFormatter: ISO8601DateFormatter

    /// 로거 기반 이벤트 발행기를 생성합니다.
    /// - Parameters:
    ///   - subsystem: 로그 서브시스템 이름입니다.
    ///   - category: 로그 카테고리 이름입니다.
    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.todo.app",
        category: String = "TodoEvent"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.dateFormatter = formatter
    }

    /// TODO 이벤트를 문자열로 구성해 시스템 로그로 기록합니다.
    /// - Parameter event: 기록할 TODO 도메인 이벤트입니다.
    public func publish(_ event: TodoEvent) {
        logger.notice("\(format(event), privacy: .public)")
    }

    /// 이벤트 로그 메시지를 생성합니다.
    /// - Parameter event: 로그로 변환할 이벤트입니다.
    /// - Returns: 통일된 포맷의 로그 문자열입니다.
    private func format(_ event: TodoEvent) -> String {
        let timestamp = dateFormatter.string(from: event.occurredAt)
        let idDescription = event.todoID.map(String.init) ?? "-"
        return "[TodoEvent] kind=\(event.kind.rawValue) todoID=\(idDescription) at=\(timestamp)"
    }
}

private extension TodoEventKind {
    /// 로그 가독성을 위한 문자열 표현입니다.
    var rawValue: String {
        switch self {
        case .added:
            return "added"
        case .updated:
            return "updated"
        case .toggledCompletion:
            return "toggledCompletion"
        case .deleted:
            return "deleted"
        case .reordered:
            return "reordered"
        case .undoDeleted:
            return "undoDeleted"
        case .clearedAll:
            return "clearedAll"
        }
    }
}
