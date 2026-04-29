#if DEBUG
import SwiftUI

/// 스토어 이미지 캡처 시 앱을 특정 장면으로 바로 띄우기 위한 디버그 시나리오입니다.
enum StoreCaptureScenario: String {
    case main
    case add
    case edit
    case completed
    case settings

    /// 실행 환경에서 선택된 시나리오를 읽어옵니다.
    static var current: StoreCaptureScenario? {
        let processInfo = ProcessInfo.processInfo
        let defaults = UserDefaults.standard

        if let defaultsValue = defaults.string(forKey: "TODO_CAPTURE_SCENARIO")?.lowercased(),
           let scenario = StoreCaptureScenario(rawValue: defaultsValue) {
            return scenario
        }

        if let environmentValue = processInfo.environment["TODO_CAPTURE_SCENARIO"]?.lowercased(),
           let scenario = StoreCaptureScenario(rawValue: environmentValue) {
            return scenario
        }

        let arguments = processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-TodoCaptureScenario"),
              arguments.indices.contains(flagIndex + 1)
        else {
            return nil
        }

        return StoreCaptureScenario(rawValue: arguments[flagIndex + 1].lowercased())
    }

    /// 선택된 시나리오에 맞는 루트 화면을 생성합니다.
    @MainActor
    func makeRootView() -> AnyView {
        let builder = StoreCaptureBuilder()
        return builder.makeRootView(for: self)
    }
}

/// 스토어 이미지용 샘플 데이터를 만들고 시나리오별 루트 화면을 조립합니다.
@MainActor
private struct StoreCaptureBuilder {
    /// 시나리오별 루트 화면을 생성합니다.
    func makeRootView(for scenario: StoreCaptureScenario) -> AnyView {
        let fixture = StoreCaptureFixture.make(for: scenario)
        let viewModel = TodoListViewModel(
            initialItems: fixture.items,
            store: InMemoryTodoStore()
        )

        switch scenario {
        case .main:
            return AnyView(TodoListView(viewModel: viewModel))
        case .add:
            return AnyView(
                TodoListView(
                    viewModel: viewModel,
                    initialPresentation: .init(addDraft: fixture.addDraft)
                )
            )
        case .edit:
            return AnyView(
                TodoListView(
                    viewModel: viewModel,
                    initialPresentation: .init(
                        editState: .init(todoID: fixture.editTodoID, draft: fixture.editDraft)
                    )
                )
            )
        case .completed:
            return AnyView(
                NavigationStack {
                    CompletedTodoListView(viewModel: viewModel)
                }
            )
        case .settings:
            return AnyView(
                NavigationStack {
                    SettingsView(viewModel: viewModel)
                }
            )
        }
    }
}

/// 스토어 캡처용 고정 데이터 묶음입니다.
private struct StoreCaptureFixture {
    /// 기본 TODO 목록입니다.
    let items: [TodoItemViewData]
    /// 추가 팝업 초깃값입니다.
    let addDraft: TodoListView.InitialPresentation.DraftState
    /// 수정 팝업 초깃값입니다.
    let editDraft: TodoListView.InitialPresentation.DraftState
    /// 수정 팝업 대상 ID입니다.
    let editTodoID: Int

    /// 시나리오 공통 샘플 데이터를 생성합니다.
    static func make(for scenario: StoreCaptureScenario) -> StoreCaptureFixture {
        let calendar = Calendar(identifier: .gregorian)
        let now = calendar.date(from: DateComponents(year: 2026, month: 4, day: 23, hour: 9, minute: 41)) ?? Date()
        let todayAt430 = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now) ?? now
        let todayAt440 = calendar.date(bySettingHour: 16, minute: 40, second: 0, of: now) ?? now
        let tomorrowAt10 = calendar.date(byAdding: .day, value: 1, to: todayAt430) ?? todayAt430
        let completedAt = calendar.date(byAdding: .hour, value: -2, to: now) ?? now

        let baseItems = [
            TodoItemViewData(
                id: 101,
                title: "운동 30분",
                endDate: todayAt430,
                reminderOffsets: [600],
                isCompleted: false
            ),
            TodoItemViewData(
                id: 102,
                title: "회의 준비",
                endDate: todayAt440,
                reminderOffsets: [1800],
                isCompleted: false
            ),
            TodoItemViewData(
                id: 103,
                title: "우유 사기",
                endDate: tomorrowAt10,
                reminderOffsets: [3600],
                isCompleted: false
            ),
            TodoItemViewData(
                id: 201,
                title: "완료한 보고서 제출",
                endDate: calendar.date(byAdding: .day, value: -1, to: now),
                reminderOffsets: [],
                isCompleted: true,
                completedAt: completedAt
            )
        ]

        let mainScenarioItems = [
            TodoItemViewData(
                id: 104,
                title: "발표 자료 검토",
                endDate: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now,
                reminderOffsets: [900],
                isCompleted: false
            ),
            TodoItemViewData(
                id: 105,
                title: "장보기 메모 정리",
                endDate: calendar.date(byAdding: .day, value: 2, to: todayAt430) ?? todayAt430,
                reminderOffsets: [],
                isCompleted: false
            )
        ]

        let items = scenario == .main ? baseItems + mainScenarioItems : baseItems

        let addDraft = TodoListView.InitialPresentation.DraftState(
            title: "팀 점심 예약",
            hasEndDate: true,
            endDate: todayAt440,
            reminderOffsets: [600, 1800]
        )

        let editDraft = TodoListView.InitialPresentation.DraftState(
            title: "운동 30분",
            hasEndDate: true,
            endDate: todayAt430,
            reminderOffsets: [600]
        )

        return StoreCaptureFixture(
            items: items,
            addDraft: addDraft,
            editDraft: editDraft,
            editTodoID: 101
        )
    }
}
#endif
