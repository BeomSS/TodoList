import CoreData
import Foundation

// 앱 기본 저장소 구현체입니다.
// UserDefaults 대신 CoreData를 사용해 대량 데이터/확장성 측면을 개선합니다.
// 전역 singleton을 두지 않고 DI에서 인스턴스를 명시적으로 주입합니다.
public final class CoreDataTodoStore: TodoStore {
    // CoreData 영속성 컨테이너입니다.
    private let container: NSPersistentContainer
    // 접근 편의를 위한 메인 컨텍스트입니다.
    private var context: NSManagedObjectContext { container.viewContext }

    // 디스크 저장 버전 생성자입니다.
    public convenience init() {
        self.init(inMemory: false)
    }

    // inMemory=true면 SQLite 파일 대신 메모리 저장소를 사용합니다.
    // 단위 테스트에서 CoreData를 실제로 검증할 때 사용할 수 있습니다.
    public init(inMemory: Bool) {
        let model = Self.makeManagedObjectModel()
        container = NSPersistentContainer(name: "TodoModel", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first

            let storeDirectory = (appSupport ?? URL(fileURLWithPath: NSTemporaryDirectory()))
                .appendingPathComponent("TodoStore", isDirectory: true)

            try? FileManager.default.createDirectory(
                at: storeDirectory,
                withIntermediateDirectories: true
            )

            description.url = storeDirectory.appendingPathComponent("Todo.sqlite")
        }

        description.type = NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("CoreData store load failed: \(error)")
            }
        }

        // 머지 정책: 같은 객체 충돌 시 현재 메모리 값을 우선합니다.
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        context.undoManager = nil
    }

    public func loadState() -> LocalTodoPersistedState? {
        var loadedState: LocalTodoPersistedState?

        context.performAndWait {
            let records = fetchTodoRecords()
            let items = records.map { record in
                TodoItemViewData(
                    id: Int(record.value(forKey: "id") as? Int64 ?? 0),
                    title: record.value(forKey: "title") as? String ?? "",
                    endDate: record.value(forKey: "endDate") as? Date,
                    isCompleted: record.value(forKey: "isCompleted") as? Bool ?? false,
                    completedAt: record.value(forKey: "completedAt") as? Date
                )
            }

            // 저장된 메타가 없으면 기본 값을 사용합니다.
            let appState = fetchOrCreateAppState()
            loadedState = LocalTodoPersistedState(
                items: items,
                nextLocalID: Int(appState.value(forKey: "nextLocalID") as? Int64 ?? -1)
            )

            // 초기 생성 시점에는 컨텍스트 변경을 저장합니다.
            saveContextIfNeeded()
        }

        return loadedState
    }

    public func saveState(_ state: LocalTodoPersistedState) {
        context.performAndWait {
            let existingRecords = fetchTodoRecords()
            let existingByID = Dictionary(
                uniqueKeysWithValues: existingRecords.map { ($0.value(forKey: "id") as? Int64 ?? 0, $0) }
            )
            var usedIDs = Set<Int64>()

            // 전달받은 스냅샷을 기준으로 upsert(삽입/갱신)합니다.
            for (index, item) in state.items.enumerated() {
                let key = Int64(item.id)
                usedIDs.insert(key)

                let record = existingByID[key] ?? NSEntityDescription.insertNewObject(
                    forEntityName: "TodoRecord",
                    into: context
                )
                record.setValue(key, forKey: "id")
                record.setValue(item.title, forKey: "title")
                record.setValue(item.endDate, forKey: "endDate")
                record.setValue(item.isCompleted, forKey: "isCompleted")
                record.setValue(item.completedAt, forKey: "completedAt")
                record.setValue(Int64(index), forKey: "position")
            }

            // 스냅샷에 없는 항목은 삭제합니다.
            for record in existingRecords {
                let id = record.value(forKey: "id") as? Int64 ?? 0
                guard usedIDs.contains(id) == false else { continue }
                context.delete(record)
            }

            // nextLocalID 메타도 함께 저장합니다.
            let appState = fetchOrCreateAppState()
            appState.setValue(Int64(state.nextLocalID), forKey: "nextLocalID")

            saveContextIfNeeded()
        }
    }

    // 정렬된 TODO 레코드를 조회합니다.
    private func fetchTodoRecords() -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            assertionFailure("CoreData fetch TodoRecord failed: \(error)")
            return []
        }
    }

    // 앱 전역 메타(안내 노출 여부/nextLocalID)를 조회하거나 새로 만듭니다.
    private func fetchOrCreateAppState() -> NSManagedObject {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoAppState")
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let newState = NSEntityDescription.insertNewObject(
            forEntityName: "TodoAppState",
            into: context
        )
        newState.setValue(Int64(-1), forKey: "nextLocalID")
        return newState
    }

    // 변경사항이 있을 때만 저장합니다.
    private func saveContextIfNeeded() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("CoreData save failed: \(error)")
        }
    }
}

private extension CoreDataTodoStore {
    // 코드 기반 NSManagedObjectModel을 생성합니다.
    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let todoEntity = NSEntityDescription()
        todoEntity.name = "TodoRecord"
        // 테스트에서 모델 인스턴스가 여러 번 생성되어도 경고가 없도록
        // 구체 서브클래스 대신 NSManagedObject 기본 클래스를 사용합니다.
        todoEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let todoID = NSAttributeDescription()
        todoID.name = "id"
        todoID.attributeType = .integer64AttributeType
        todoID.isOptional = false

        let todoTitle = NSAttributeDescription()
        todoTitle.name = "title"
        todoTitle.attributeType = .stringAttributeType
        todoTitle.isOptional = true

        let todoCompleted = NSAttributeDescription()
        todoCompleted.name = "isCompleted"
        todoCompleted.attributeType = .booleanAttributeType
        todoCompleted.isOptional = false

        let todoEndDate = NSAttributeDescription()
        todoEndDate.name = "endDate"
        todoEndDate.attributeType = .dateAttributeType
        todoEndDate.isOptional = true

        let todoCompletedAt = NSAttributeDescription()
        todoCompletedAt.name = "completedAt"
        todoCompletedAt.attributeType = .dateAttributeType
        todoCompletedAt.isOptional = true

        let todoPosition = NSAttributeDescription()
        todoPosition.name = "position"
        todoPosition.attributeType = .integer64AttributeType
        todoPosition.isOptional = false

        todoEntity.properties = [todoID, todoTitle, todoEndDate, todoCompleted, todoCompletedAt, todoPosition]

        let appStateEntity = NSEntityDescription()
        appStateEntity.name = "TodoAppState"
        appStateEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let nextLocalID = NSAttributeDescription()
        nextLocalID.name = "nextLocalID"
        nextLocalID.attributeType = .integer64AttributeType
        nextLocalID.isOptional = false

        appStateEntity.properties = [nextLocalID]

        model.entities = [todoEntity, appStateEntity]
        return model
    }
}
