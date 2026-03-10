import Foundation

/// UseCase 계층이 의존하는 TODO 서비스 계약입니다.
/// ViewModel은 서비스 구현체가 아니라 UseCase를 통해서만 기능을 사용합니다.
public protocol TodoServiceType: AnyObject {
    /// 현재 TODO 전체 목록입니다.
    var items: [TodoItemViewData] { get }
    /// 마지막 삭제에 대한 Undo 토스트 상태입니다.
    var undoToast: UndoToastState? { get }

    /// TODO를 추가합니다.
    /// - Parameters:
    ///   - title: 할 일 제목입니다.
    ///   - endDate: 마감 시각입니다.
    ///   - reminderOffsets: 알림 오프셋(초) 목록입니다.
    func addTodo(title: String, endDate: Date?, reminderOffsets: [Int])

    /// TODO를 수정합니다.
    /// - Parameters:
    ///   - id: 수정 대상 TODO ID입니다.
    ///   - title: 변경할 제목입니다.
    ///   - endDate: 변경할 마감 시각입니다.
    ///   - reminderOffsets: 변경할 알림 오프셋(초) 목록입니다.
    func updateTodo(id: Int, title: String, endDate: Date?, reminderOffsets: [Int])

    /// TODO 완료 상태를 토글합니다.
    /// - Parameter id: 토글 대상 TODO ID입니다.
    func toggleCompletion(id: Int)

    /// TODO를 삭제합니다.
    /// - Parameter id: 삭제 대상 TODO ID입니다.
    func deleteTodo(id: Int)

    /// 목록 순서를 이동합니다.
    /// - Parameters:
    ///   - fromOffsets: 원본 인덱스 집합입니다.
    ///   - toOffset: 이동 목적지 인덱스입니다.
    func moveTodos(fromOffsets: IndexSet, toOffset: Int)

    /// ID 기준으로 전체 목록 순서를 재정렬합니다.
    /// - Parameter orderedIDs: 최종 순서대로 정렬된 TODO ID 목록입니다.
    func reorderTodos(orderedIDs: [Int])

    /// 마지막 삭제를 복구합니다.
    func undoLastDeletion()

    /// Undo 토스트 상태를 비웁니다.
    func clearUndoToast()

    /// 앱의 TODO 데이터를 전체 삭제합니다.
    func clearAllTodos()
}
