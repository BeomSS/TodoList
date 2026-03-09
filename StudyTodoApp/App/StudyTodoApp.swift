#if canImport(UIKit)
import SwiftUI

// 앱 실행 진입점입니다.
@main
struct StudyTodoApp: App {
    // 앱 전체에서 사용할 의존성 조립 객체입니다.
    private let container = AppDIContainer()

    // 앱의 화면(Scene) 트리를 정의합니다.
    var body: some Scene {
        WindowGroup {
            // DI 컨테이너가 만들어 준 ViewModel을 루트 뷰에 주입합니다.
            TodoListView(viewModel: container.makeTodoListViewModel())
        }
    }
}
#endif
