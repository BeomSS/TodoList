import Foundation

// 하단 Undo 토스트의 상태 모델입니다.
public struct UndoToastState: Identifiable, Equatable {
    // SwiftUI 리스트/전환에 사용할 식별자입니다.
    public let id = UUID()
    // 사용자에게 보여줄 토스트 문구입니다.
    public let message: String

    // 마지막으로 삭제된 항목입니다.
    let deletedItem: TodoItemViewData
    // 복구 시 원래 위치로 넣기 위한 인덱스입니다.
    let deletedIndex: Int
}
