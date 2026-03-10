import Foundation

/// 앱/위젯이 함께 사용하는 App Group 설정 상수입니다.
public enum AppGroupConfig {
    /// 앱과 위젯이 같은 UserDefaults를 공유하기 위한 그룹 식별자입니다.
    /// 실제 배포 시에는 Apple Developer에 등록된 App Group과 동일해야 합니다.
    public static let suiteName = "group.com.hmp.sample.todo"

    /// 위젯 스냅샷 JSON을 저장할 UserDefaults 키입니다.
    public static let todaySnapshotKey = "todo.widget.today.snapshot"
}
