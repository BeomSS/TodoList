import Foundation
import WidgetKit

/// 위젯 타임라인 공급자입니다.
/// 앱이 저장한 App Group 스냅샷을 읽어 위젯 엔트리를 생성합니다.
struct TodayTodoProvider: TimelineProvider {
    /// 위젯 갤러리/로딩 중에 보여줄 플레이스홀더를 반환합니다.
    /// - Parameter context: 위젯 컨텍스트입니다.
    /// - Returns: 샘플 엔트리입니다.
    func placeholder(in context: Context) -> TodayTodoEntry {
        TodayTodoEntry(
            date: Date(),
            todayCount: 2,
            items: [
                TodayTodoEntryItem(id: 1, title: "회의 자료 마무리", endDate: Date().addingTimeInterval(3_600)),
                TodayTodoEntryItem(id: 2, title: "운동 30분", endDate: Date().addingTimeInterval(7_200))
            ]
        )
    }

    /// 스냅샷 엔트리를 생성해 반환합니다.
    /// - Parameters:
    ///   - context: 위젯 컨텍스트입니다.
    ///   - completion: 생성된 엔트리를 전달하는 콜백입니다.
    func getSnapshot(in context: Context, completion: @escaping (TodayTodoEntry) -> Void) {
        completion(loadEntry())
    }

    /// 타임라인을 생성해 시스템에 전달합니다.
    /// - Parameters:
    ///   - context: 위젯 컨텍스트입니다.
    ///   - completion: 타임라인 전달 콜백입니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayTodoEntry>) -> Void) {
        let entry = loadEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    /// App Group의 공유 스냅샷을 읽어 엔트리로 변환합니다.
    /// - Returns: 위젯 렌더링에 사용할 엔트리입니다.
    private func loadEntry() -> TodayTodoEntry {
        guard let defaults = UserDefaults(suiteName: AppGroupConfig.suiteName) else {
            return TodayTodoEntry(date: Date(), todayCount: 0, items: [])
        }

        guard let data = defaults.data(forKey: AppGroupConfig.todaySnapshotKey) else {
            return TodayTodoEntry(date: Date(), todayCount: 0, items: [])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let snapshot = try? decoder.decode(SharedTodayTodoWidgetSnapshot.self, from: data) else {
            return TodayTodoEntry(date: Date(), todayCount: 0, items: [])
        }

        return TodayTodoEntry(
            date: snapshot.updatedAt,
            todayCount: snapshot.todayCount,
            items: snapshot.items.map {
                TodayTodoEntryItem(id: $0.id, title: $0.title, endDate: $0.endDate)
            }
        )
    }
}
