import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// 메인 앱에서 위젯용 스냅샷을 UserDefaults(App Group)에 저장하는 저장소입니다.
struct TodayTodoWidgetSnapshotStore: TodayTodoWidgetSnapshotWriting {
    // 테스트/호환성을 위해 현재 시각 공급자를 주입 가능합니다.
    private let nowProvider: () -> Date

    /// 위젯 스냅샷 저장소를 생성합니다.
    /// - Parameter nowProvider: 현재 시각 공급자입니다.
    init(nowProvider: @escaping () -> Date = Date.init) {
        self.nowProvider = nowProvider
    }

    /// 현재 TODO 목록을 위젯 스냅샷으로 계산해 저장합니다.
    /// - Parameter items: 전체 TODO 목록입니다.
    func save(items: [TodoItemViewData]) {
        guard let defaults = UserDefaults(suiteName: AppGroupConfig.suiteName) else {
            // App Group이 미설정이면 저장을 건너뜁니다.
            return
        }

        let calendar = Calendar.current
        let now = nowProvider()
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        // 진행중 + 마감일이 오늘 범위에 포함되는 항목만 추립니다.
        let filteredTodayItems = items
            .filter { item in
                guard item.isCompleted == false else { return false }
                guard let endDate = item.endDate else { return false }
                return (startOfDay ..< endOfDay).contains(endDate)
            }
            .sorted { $0.endDate ?? .distantFuture < $1.endDate ?? .distantFuture }

        let todayItems = filteredTodayItems
            .prefix(TodayTodoWidgetConfig.maxStoredItemCount)
            .map { item in
                SharedTodayTodoWidgetItem(
                    id: item.id,
                    title: item.title,
                    endDate: item.endDate ?? now
                )
            }

        let snapshot = SharedTodayTodoWidgetSnapshot(
            updatedAt: now,
            // 위젯 헤더 카운트는 전체 \"오늘 마감\" 건수를 보여줍니다.
            todayCount: filteredTodayItems.count,
            items: Array(todayItems)
        )

        // 위젯에서 바로 decode할 수 있게 JSON Data로 저장합니다.
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let encoded = try? encoder.encode(snapshot) else { return }
        defaults.set(encoded, forKey: AppGroupConfig.todaySnapshotKey)

        // 앱에서 데이터가 바뀌면 오늘 위젯을 즉시 재요청해 반영 지연을 줄입니다.
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: TodayTodoWidgetConfig.kind)
        #endif
    }
}
