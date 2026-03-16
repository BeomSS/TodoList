import AppIntents
import SwiftUI

/// 앱 실행 진입점입니다.
@main
struct StudyTodoApp: App {
    // 앱 전체에서 사용할 의존성 조립 객체입니다.
    private let container = AppDIContainer.shared
    // 알림 탭 이벤트를 처리하기 위한 UIApplicationDelegate 어댑터입니다.
    @UIApplicationDelegateAdaptor(TodoAppDelegate.self) private var appDelegate

    /// 앱 초기화 시 단축어 파라미터를 최신 상태로 갱신합니다.
    init() {
        TodoAppShortcuts.updateAppShortcutParameters()
    }

    /// 앱의 화면(Scene) 트리를 정의합니다.
    var body: some Scene {
        WindowGroup {
            // DI 컨테이너가 만들어 준 ViewModel을 루트 뷰에 주입합니다.
            TodoListView(viewModel: container.makeTodoListViewModel())
        }
    }
}

/// Siri/단축어에서 TODO를 추가하는 앱 인텐트입니다.
/// 음성 예시: "시리야, Todo에서 우유 사기 추가해줘"
struct AddTodoFromVoiceIntent: AppIntent {
    /// 인텐트 이름입니다.
    static let title: LocalizedStringResource = "할 일 추가"
    /// 인텐트 설명입니다.
    static let description = IntentDescription("Siri 또는 단축어로 할 일을 추가합니다.")
    /// 인텐트 실행 시 앱을 강제로 전면에 띄우지 않습니다.
    static let openAppWhenRun = false

    /// 사용자가 말한 TODO 본문입니다.
    /// 예: "빨래 하기 오늘 3시까지로"
    @Parameter(
        title: "할 일 입력",
        requestValueDialog: IntentDialog("추가할 할 일을 알려주세요.")
    )
    var todoPhrase: String

    /// 파라미터 요약 문구입니다.
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$todoPhrase) 할 일을 추가")
    }

    /// 인텐트 본 실행부입니다.
    /// 입력 유효성을 확인하고 TODO를 추가한 뒤 사용자에게 결과를 말해줍니다.
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let parsed = TodoVoiceTextParser().parse(todoPhrase)
        guard parsed.title.isEmpty == false else {
            return .result(dialog: IntentDialog("빈 제목은 추가할 수 없어요."))
        }

        let added = AppDIContainer.shared.addTodoFromSystem(
            title: parsed.title,
            endDate: parsed.dueDate
        )

        guard added else {
            return .result(dialog: IntentDialog("할 일을 추가하지 못했어요. 제목을 확인해 주세요."))
        }

        if parsed.dueDate != nil {
            return .result(dialog: IntentDialog("마감일과 함께 할 일을 추가했어요."))
        }
        return .result(dialog: IntentDialog("할 일을 추가했어요."))
    }
}

/// 앱에서 노출할 Siri/단축어 문구 집합입니다.
struct TodoAppShortcuts: AppShortcutsProvider {
    /// 단축어 타일의 기본 색입니다.
    static var shortcutTileColor: ShortcutTileColor = .orange

    /// 사용자에게 제안/검색될 단축어 목록입니다.
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTodoFromVoiceIntent(),
            phrases: [
                // 제목만 추가하는 기본 문구입니다.
                "\(.applicationName)에서 \(\.$todoPhrase) 추가해줘",
                // 영어 발화 대응 문구도 함께 제공합니다.
                "Add \(\.$todoPhrase) in \(.applicationName)"
            ],
            shortTitle: "할 일 추가",
            systemImageName: "plus.circle"
        )
    }
}

/// Siri 발화 문자열에서 제목/마감일을 분리하는 파서입니다.
/// iOS 기본 `NSDataDetector`를 사용해 날짜 표현을 인식하고, 나머지 텍스트를 제목으로 정리합니다.
private struct TodoVoiceTextParser {
    /// 발화 문자열을 TODO 입력으로 변환합니다.
    /// - Parameter raw: 사용자가 말한 원문입니다.
    /// - Returns: 정규화된 제목과 선택 마감일입니다.
    func parse(_ raw: String) -> (title: String, dueDate: Date?) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return ("", nil) }

        let detectedDate = detectDate(in: trimmed)
        var titleCandidate = trimmed

        // 날짜로 해석된 구간은 제목에서 제거합니다.
        if let dateRange = detectedDate?.range {
            titleCandidate.removeSubrange(dateRange)
        }

        // 한국어 조사/접미 표현을 정리해 제목 가독성을 높입니다.
        titleCandidate = normalizeTitleCandidate(titleCandidate)

        // 정리 결과가 비면 원문을 제목으로 사용해 데이터 손실을 피합니다.
        let normalizedTitle = titleCandidate.isEmpty ? trimmed : titleCandidate
        return (normalizedTitle, detectedDate?.date)
    }

    // 텍스트 내 날짜를 탐지합니다.
    private func detectDate(in text: String) -> (date: Date, range: Range<String.Index>)? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return nil
        }
        let searchRange = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = detector.matches(in: text, options: [], range: searchRange).first(where: { $0.date != nil }) else {
            return nil
        }
        guard
            let date = match.date,
            let swiftRange = Range(match.range, in: text)
        else {
            return nil
        }
        return (date, swiftRange)
    }

    // 제목 후보 문자열에서 불필요 조사/연결 표현을 제거합니다.
    private func normalizeTitleCandidate(_ title: String) -> String {
        var normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // 문자열 내부 글자를 훼손하지 않도록 조사/접미 표현은 "문장 끝"에 있을 때만 제거합니다.
        let suffixPatterns = [
            #"\s*(까지로|까지|로|에|마감)\s*$"#,
            #"\s*(by|due)\s*$"#
        ]

        for pattern in suffixPatterns {
            normalized = normalized.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        // 다중 공백을 하나로 줄여 저장 문자열을 안정화합니다.
        let parts = normalized
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
        return parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
