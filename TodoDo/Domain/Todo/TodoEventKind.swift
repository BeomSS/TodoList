import Foundation

/// TODO 도메인에서 발생하는 주요 이벤트 종류입니다.
public enum TodoEventKind: Sendable {
    /// 할 일 추가 이벤트입니다.
    case added
    /// 할 일 수정 이벤트입니다.
    case updated
    /// 완료/미완료 토글 이벤트입니다.
    case toggledCompletion
    /// 할 일 삭제 이벤트입니다.
    case deleted
    /// 목록 순서 변경 이벤트입니다.
    case reordered
    /// 삭제 복구 이벤트입니다.
    case undoDeleted
    /// 전체 데이터 삭제 이벤트입니다.
    case clearedAll
}
