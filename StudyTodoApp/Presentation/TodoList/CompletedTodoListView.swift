import SwiftUI

// 완료된 TODO만 모아 보여주는 화면입니다.
public struct CompletedTodoListView: View {
    // 부모 화면에서 생성한 동일 ViewModel 인스턴스를 관찰합니다.
    @ObservedObject private var viewModel: TodoListViewModel
    // 완료 목록에서 되돌리기 실행 후 노출할 토스트 상태입니다.
    @State private var restoreToast: RestoreToastState?
    // 토스트 자동 닫힘 예약 작업입니다.
    @State private var dismissRestoreToastTask: Task<Void, Never>?
    // 되돌리기 확인 팝업 표시 상태입니다.
    @State private var isRestoreConfirmPopupPresented = false
    // 확인 팝업에서 현재 되돌리기 대상 항목입니다.
    @State private var pendingRestoreItem: TodoItemViewData?
    // 확인 팝업의 "항상 허용" 체크 상태입니다.
    @State private var alwaysAllowRestoreToggle = false
    // 체크 후 "예"를 누르면 이후 팝업 없이 즉시 되돌리기합니다.
    @AppStorage(TodoAppStorageKey.restoreAlwaysAllow) private var restoreAlwaysAllowed = false

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            TodoTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 14) {
                summaryCard
                listCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .overlay(alignment: .bottom) {
            // 메인 화면의 삭제 인터랙션과 동일하게 하단 토스트 + 취소 복구를 제공합니다.
            if let toast = restoreToast {
                restoreUndoToast(toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
        .overlay {
            if isRestoreConfirmPopupPresented {
                restoreConfirmPopup
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .navigationTitle("완료한 일")
        .todoNavigationBarInline()
        // 메인 화면 삭제와 동일한 톤으로 목록 변화 애니메이션을 맞춥니다.
        .animation(.spring(response: 0.28, dampingFraction: 0.92), value: viewModel.completedItems.map(\.id))
        .animation(.spring(response: 0.28, dampingFraction: 0.92), value: restoreToast)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isRestoreConfirmPopupPresented)
        .onDisappear {
            dismissRestoreToastTask?.cancel()
        }
    }

    // 완료 목록 요약 카드입니다.
    private var summaryCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.green.opacity(0.16))
                    .frame(width: 44, height: 44)

                Image(systemName: "checkmark.seal.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("완료 아카이브")
                    .font(.subheadline.weight(.semibold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.secondary)

                Text("\(viewModel.completedItems.count)개 완료")
                    .font(.title2.weight(.black))
                    .todoRoundedFontDesign()
            }

            Spacer()
        }
        .padding(16)
        .todoCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("완료 아카이브")
        .accessibilityValue("총 \(viewModel.completedItems.count)개")
    }

    // 완료 목록 영역입니다.
    @ViewBuilder
    private var listCard: some View {
        if viewModel.completedItems.isEmpty {
            emptyState
        } else {
            List {
                ForEach(viewModel.completedItems) { item in
                    completedRow(item)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                TodoHaptics.warning()
                                viewModel.deleteTodo(id: item.id)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .todoCardStyle()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    // 완료 목록이 비어 있을 때 노출할 상태 화면입니다.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.green)

            Text("완료된 할 일이 아직 없어요")
                .font(.title3.weight(.bold))
                .todoRoundedFontDesign()

            Text("진행중 목록에서 할 일을 완료하면 이곳에 쌓입니다.")
                .font(.footnote.weight(.medium))
                .todoRoundedFontDesign()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .todoCardStyle()
    }

    // 완료 목록의 개별 행 UI입니다.
    private func completedRow(_ item: TodoItemViewData) -> some View {
        return HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.weight(.semibold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.primary)

                Text("완료됨")
                    .font(.caption.weight(.bold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.green)

                if let completedAt = item.completedAt {
                    Text("완료 \(DateDisplay.todoDateTime.string(from: completedAt))")
                        .font(.caption2.weight(.semibold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                requestRestore(for: item)
            } label: {
                Text("되돌리기")
                    .font(.caption.weight(.bold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.blue.opacity(0.12))
                    )
            }
            .buttonStyle(TodoPressableButtonStyle())
            .accessibilityLabel("\(item.title) 진행중으로 되돌리기")
        }
        .padding(.vertical, 7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("완료됨")
    }

    // 되돌리기 요청 시 설정에 따라 확인 팝업 또는 즉시 실행을 분기합니다.
    private func requestRestore(for item: TodoItemViewData) {
        if restoreAlwaysAllowed {
            restoreTodo(item)
            return
        }

        pendingRestoreItem = item
        alwaysAllowRestoreToggle = false
        isRestoreConfirmPopupPresented = true
    }

    // 완료 항목을 진행중으로 이동하고, 메인 삭제와 동일한 취소 토스트를 띄웁니다.
    private func restoreTodo(_ item: TodoItemViewData) {
        TodoHaptics.selection()
        Task {
            await viewModel.toggleCompletion(for: item.id)
            restoreToast = RestoreToastState(
                message: "\"\(item.title)\" 진행중으로 이동됨",
                restoredItemID: item.id
            )
            scheduleRestoreToastDismiss()
        }
    }

    // 되돌리기 확인 커스텀 팝업입니다.
    private var restoreConfirmPopup: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture {
                    closeRestoreConfirmPopup()
                }

            VStack(alignment: .leading, spacing: 14) {
                Text("진행중으로 되돌릴까요?")
                    .font(.title3.weight(.bold))
                    .todoRoundedFontDesign()

                Text("완료 목록에서 항목이 빠지고 진행중 목록으로 이동합니다.")
                    .font(.subheadline.weight(.medium))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.secondary)

                Toggle(isOn: $alwaysAllowRestoreToggle) {
                    Text("항상 허용 (다음부터 묻지 않음)")
                        .font(.footnote.weight(.semibold))
                        .todoRoundedFontDesign()
                }
                .toggleStyle(.switch)

                HStack(spacing: 10) {
                    Button("아니오") {
                        TodoHaptics.selection()
                        closeRestoreConfirmPopup()
                    }
                    .font(.body.weight(.semibold))
                    .todoRoundedFontDesign()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(TodoTheme.popupCancelBackgroundColor)
                    )
                    .buttonStyle(TodoPressableButtonStyle())

                    Button("예") {
                        TodoHaptics.success()
                        if alwaysAllowRestoreToggle {
                            restoreAlwaysAllowed = true
                        }
                        if let pendingRestoreItem {
                            restoreTodo(pendingRestoreItem)
                        }
                        closeRestoreConfirmPopup()
                    }
                    .font(.body.weight(.bold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue)
                    )
                    .buttonStyle(TodoPressableButtonStyle())
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
            )
            .padding(.horizontal, 24)
        }
        .accessibilityElement(children: .contain)
    }

    // 하단 복구 취소 토스트 UI입니다.
    private func restoreUndoToast(_ toast: RestoreToastState) -> some View {
        HStack(spacing: 10) {
            Text(toast.message)
                .font(.subheadline.weight(.semibold))
                .todoRoundedFontDesign()
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 8)

            Button("취소") {
                TodoHaptics.success()
                dismissRestoreToastTask?.cancel()
                Task {
                    await viewModel.toggleCompletion(for: toast.restoredItemID)
                    restoreToast = nil
                }
            }
            .font(.subheadline.weight(.bold))
            .todoRoundedFontDesign()
            .foregroundStyle(.white)
            .buttonStyle(TodoPressableButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.82))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(toast.message)
        .accessibilityHint("취소 버튼을 누르면 완료 목록으로 되돌립니다.")
    }

    // 토스트를 4초 후 자동으로 숨깁니다.
    private func scheduleRestoreToastDismiss() {
        dismissRestoreToastTask?.cancel()

        dismissRestoreToastTask = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard Task.isCancelled == false else { return }
            await MainActor.run {
                restoreToast = nil
            }
        }
    }

    // 팝업 관련 임시 상태를 공통으로 정리합니다.
    private func closeRestoreConfirmPopup() {
        isRestoreConfirmPopupPresented = false
        alwaysAllowRestoreToggle = false
        pendingRestoreItem = nil
    }

}

// 완료 목록에서 진행중 이동 후 표시할 토스트 상태입니다.
private struct RestoreToastState: Equatable {
    // 토스트 본문 메시지입니다.
    let message: String
    // 진행중으로 이동된 항목 ID입니다.
    let restoredItemID: Int
}
