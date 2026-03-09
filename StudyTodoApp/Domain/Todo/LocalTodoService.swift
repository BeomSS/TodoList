import Foundation

// UseCase 계층이 의존하는 TODO 서비스 계약입니다.
// ViewModel은 서비스 구현체가 아니라 UseCase를 통해서만 기능을 사용합니다.
public protocol TodoServiceType: AnyObject {
    var items: [TodoItemViewData] { get }
    var undoToast: UndoToastState? { get }

    func addTodo(title: String, endDate: Date?)
    func updateTodo(id: Int, title: String, endDate: Date?)
    func toggleCompletion(id: Int)
    func deleteTodo(id: Int)
    func moveTodos(fromOffsets: IndexSet, toOffset: Int)
    func reorderTodos(orderedIDs: [Int])
    func undoLastDeletion()
    func clearUndoToast()
    func clearAllTodos()
}

// 할 일 제목 정규화(트림/중복 공백 제거 등) 규칙입니다.
public struct TodoTitleNormalizer {
    public init() {}

    // 사용자 입력 문자열을 저장하기 적합한 형태로 정리합니다.
    public func normalize(_ raw: String) -> String {
        // 줄바꿈/연속 공백을 단일 공백으로 압축합니다.
        let collapsed = raw
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")

        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// 로컬 TODO 비즈니스 로직을 담당하는 서비스입니다.
public final class LocalTodoService: TodoServiceType {
    // 영속 저장소(CoreData 등)입니다.
    private var store: TodoStore
    // 현재 시각 주입 함수입니다. 테스트에서 고정 시각을 넣기 쉽습니다.
    private let nowProvider: () -> Date
    // 제목 정규화 규칙입니다.
    private let titleNormalizer: TodoTitleNormalizer

    // 현재 TODO 목록입니다.
    public private(set) var items: [TodoItemViewData] = []
    // 로컬 신규 TODO ID 생성기입니다.
    public private(set) var nextLocalID: Int = -1
    // 마지막 삭제 Undo 토스트 상태입니다.
    public private(set) var undoToast: UndoToastState?

    public init(
        store: TodoStore,
        nowProvider: @escaping () -> Date = Date.init,
        titleNormalizer: TodoTitleNormalizer = TodoTitleNormalizer(),
        initialItems: [TodoItemViewData] = []
    ) {
        self.store = store
        self.nowProvider = nowProvider
        self.titleNormalizer = titleNormalizer

        // 저장된 스냅샷이 있으면 우선 복원합니다.
        if let saved = store.loadState() {
            items = saved.items
            nextLocalID = saved.nextLocalID
        } else if !initialItems.isEmpty {
            // 초기 데이터가 주입되면 한 번만 부트스트랩합니다.
            items = initialItems
            nextLocalID = min(-1, (initialItems.map(\.id).min() ?? 0) - 1)
        }

        // 앱 시작 시점에 저장소와 메모리 상태를 동기화합니다.
        persist()
    }

    public func addTodo(title: String, endDate: Date?) {
        // 입력 정규화 후 빈 문자열이면 무시합니다.
        let normalizedTitle = titleNormalizer.normalize(title)
        guard normalizedTitle.isEmpty == false else { return }

        let newItem = TodoItemViewData(
            id: nextLocalID,
            title: normalizedTitle,
            endDate: endDate,
            isCompleted: false,
            completedAt: nil
        )

        // 최신 항목이 위로 오도록 앞쪽에 삽입합니다.
        nextLocalID -= 1
        items.insert(newItem, at: 0)
        persist()
    }

    // 기존 TODO 제목/마감일을 수정합니다.
    public func updateTodo(id: Int, title: String, endDate: Date?) {
        let normalizedTitle = titleNormalizer.normalize(title)
        guard normalizedTitle.isEmpty == false else { return }
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let current = items[index]
        items[index] = TodoItemViewData(
            id: current.id,
            title: normalizedTitle,
            endDate: endDate,
            isCompleted: current.isCompleted,
            completedAt: current.completedAt
        )
        persist()
    }

    public func toggleCompletion(id: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let current = items[index]
        let newCompleted = !current.isCompleted
        let completedAt = newCompleted ? nowProvider() : nil

        // 불변 모델을 재생성해 상태를 치환합니다.
        items[index] = TodoItemViewData(
            id: current.id,
            title: current.title,
            endDate: current.endDate,
            isCompleted: newCompleted,
            completedAt: completedAt
        )

        persist()
    }

    public func deleteTodo(id: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let removed = items.remove(at: index)
        undoToast = UndoToastState(
            message: "\"\(removed.title)\" 삭제됨",
            deletedItem: removed,
            deletedIndex: index
        )

        // 삭제는 즉시 저장하고, Undo 가능 상태를 함께 유지합니다.
        persist()
    }

    // 드래그 정렬 결과를 반영하고 저장합니다.
    public func moveTodos(fromOffsets: IndexSet, toOffset: Int) {
        guard fromOffsets.isEmpty == false else { return }

        // IndexSet 이동 규칙을 서비스 계층에서 직접 구현해 UI 프레임워크 의존을 없앱니다.
        let sourceIndexes = fromOffsets.sorted()
        let movingItems = sourceIndexes.map { items[$0] }

        // 뒤에서부터 제거해야 인덱스 붕괴를 피할 수 있습니다.
        for index in sourceIndexes.reversed() {
            items.remove(at: index)
        }

        // 제거된 항목이 목적지보다 앞에 있었다면 목적지 인덱스를 보정합니다.
        var adjustedDestination = toOffset
        for index in sourceIndexes where index < toOffset {
            adjustedDestination -= 1
        }
        adjustedDestination = min(max(adjustedDestination, 0), items.count)

        items.insert(contentsOf: movingItems, at: adjustedDestination)
        persist()
    }

    // 전달받은 ID 순서대로 전체 목록을 재배열합니다.
    // 메인(진행중) 목록만 이동한 뒤 완료 목록을 뒤에 유지하고 싶을 때 사용합니다.
    public func reorderTodos(orderedIDs: [Int]) {
        guard orderedIDs.isEmpty == false else { return }

        let currentByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        var reordered: [TodoItemViewData] = []
        reordered.reserveCapacity(items.count)

        // 요청된 순서대로 기존 항목을 재배치합니다.
        for id in orderedIDs {
            guard let item = currentByID[id] else { continue }
            reordered.append(item)
        }

        // 누락된 항목이 있으면 기존 순서를 유지해 뒤에 붙입니다.
        let orderedSet = Set(orderedIDs)
        for item in items where orderedSet.contains(item.id) == false {
            reordered.append(item)
        }

        guard reordered.isEmpty == false else { return }
        items = reordered
        persist()
    }

    public func undoLastDeletion() {
        guard let undoToast else { return }

        // 인덱스 범위를 보정해 안전하게 복원합니다.
        let restoreIndex = min(max(undoToast.deletedIndex, 0), items.count)
        items.insert(undoToast.deletedItem, at: restoreIndex)

        self.undoToast = nil
        persist()
    }

    public func clearUndoToast() {
        undoToast = nil
    }

    // 앱의 TODO 데이터를 전체 삭제하고 초기 상태로 되돌립니다.
    public func clearAllTodos() {
        items.removeAll()
        undoToast = nil
        nextLocalID = -1
        persist()
    }

    // 목록/ID 상태를 저장소에 반영합니다.
    private func persist() {
        store.saveState(
            LocalTodoPersistedState(
                items: items,
                nextLocalID: nextLocalID
            )
        )
    }
}
