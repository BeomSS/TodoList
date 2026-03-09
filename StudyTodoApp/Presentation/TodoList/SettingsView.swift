import SwiftUI

// 앱 동작 관련 사용자 설정 화면입니다.
public struct SettingsView: View {
    // 설정 화면을 닫을 때 사용하는 dismiss 액션입니다.
    @Environment(\.dismiss) private var dismiss
    // 메인 화면과 동일 ViewModel을 공유해 설정 동작을 앱 상태에 즉시 반영합니다.
    @ObservedObject private var viewModel: TodoListViewModel
    // 완료 화면 되돌리기 확인 팝업 생략 여부입니다.
    @AppStorage(TodoAppStorageKey.restoreAlwaysAllow) private var restoreAlwaysAllowed = false
    // 데이터 삭제 확인 알럿 표시 상태입니다.
    @State private var isDeleteAllAlertPresented = false

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            TodoTheme.backgroundGradient.ignoresSafeArea()

            Form {
                Section("완료 화면") {
                    // 켜면 완료 항목 되돌리기 시 확인 팝업을 건너뜁니다.
                    Toggle("되돌리기 확인 팝업 생략", isOn: $restoreAlwaysAllowed)

                    // 사용자가 언제든 기본 동작(확인 팝업 표시)으로 복원할 수 있습니다.
                    Button("설정값을 기본값으로 되돌리기") {
                        TodoHaptics.selection()
                        restoreAlwaysAllowed = false
                    }
                    .buttonStyle(TodoPressableButtonStyle())
                }

                Section("데이터") {
                    // 저장된 TODO 데이터를 초기화합니다.
                    Button("앱 데이터 삭제") {
                        TodoHaptics.warning()
                        isDeleteAllAlertPresented = true
                    }
                    .foregroundStyle(.red)
                    .buttonStyle(TodoPressableButtonStyle())
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("설정")
        .todoNavigationBarInline()
        .alert("앱 데이터를 삭제할까요?", isPresented: $isDeleteAllAlertPresented) {
            Button("아니오", role: .cancel) {}
            Button("삭제", role: .destructive) {
                TodoHaptics.success()
                viewModel.clearAllAppData()
                restoreAlwaysAllowed = false
                // 삭제 완료 후 설정 화면을 닫아 메인(빈 목록)으로 자연스럽게 복귀합니다.
                dismiss()
            }
        } message: {
            Text("진행중/완료 목록이 모두 삭제되며 되돌릴 수 없습니다.")
        }
    }
}
