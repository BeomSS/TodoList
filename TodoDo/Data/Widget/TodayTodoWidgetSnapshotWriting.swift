import Foundation

/// 메인 앱에서 위젯 스냅샷을 기록하는 계약입니다.
/// 저장 매체(UserDefaults, 파일, 네트워크 캐시) 변경 시 ViewModel 수정 없이 교체할 수 있습니다.
public protocol TodayTodoWidgetSnapshotWriting {
    /// 위젯이 사용할 TODO 스냅샷을 저장합니다.
    /// - Parameter items: 저장 기준이 되는 전체 TODO 목록입니다.
    func save(items: [TodoItemViewData])
}
