import SwiftUI
import UIKit

/// 진행 중 TODO를 관리하는 메인 화면입니다.
public struct TodoListView: View {
    // MARK: - State

    // 화면 생명주기 동안 ViewModel 인스턴스를 유지합니다.
    @StateObject private var viewModel: TodoListViewModel

    // 입력창 임시 상태
    @State private var draftTitle = ""
    @State private var draftHasEndDate = false
    @State private var draftEndDate = Date()
    @State private var draftReminderOffsets: [Int] = []
    @State private var isAddTodoPopupPresented = false
    // 수정 팝업 임시 상태
    @State private var editDraftTitle = ""
    @State private var editHasEndDate = false
    @State private var editEndDate = Date()
    @State private var editReminderOffsets: [Int] = []
    @State private var isEditTodoPopupPresented = false
    @State private var editingTodoID: Int?
    // 알림 권한 거부 상태 안내 알럿 노출 여부입니다.
    @State private var isReminderPermissionAlertPresented = false
    // 알럿에서 현재 처리 중인 액션(추가/수정)입니다.
    @State private var reminderPermissionAlertMode: ReminderPermissionAlertMode = .add
    // 알림 탭으로 선택된 TODO ID를 전달받는 공유 센터입니다.
    @StateObject private var notificationSelectionCenter = TodoNotificationSelectionCenter.shared
    // 화면에서 강조 표시 중인 TODO ID입니다.
    @State private var highlightedTodoID: Int?
    // 강조 표시 자동 해제를 위한 예약 작업입니다.
    @State private var clearHighlightedTodoTask: Task<Void, Never>?
    // 특정 TODO로 스크롤하기 위한 임시 대상 ID입니다.
    @State private var pendingScrollTodoID: Int?
    // 정렬 모드 활성 상태입니다. true일 때만 리스트 이동 핸들을 노출합니다.
    @State private var isReorderMode = false
    // 완료 처리 애니메이션이 진행 중인 TODO ID 집합입니다.
    @State private var completingTodoIDs: Set<Int> = []
    @FocusState private var isPopupInputFocused: Bool

    // MARK: - Init

    /// 메인 TODO 화면을 생성합니다.
    /// - Parameter viewModel: 화면 상태와 비즈니스 액션을 제공하는 ViewModel입니다.
    public init(viewModel: TodoListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Derived Values

    // 완료 개수
    private var completedCount: Int {
        viewModel.completedItems.count
    }

    // 전체 개수
    private var totalCount: Int {
        viewModel.inProgressItems.count + viewModel.completedItems.count
    }

    // 진행중 개수
    private var inProgressCount: Int {
        viewModel.inProgressItems.count
    }

    // 마감일이 지난 진행중 항목 개수입니다.
    private var overdueCount: Int {
        viewModel.inProgressItems.filter { item in
            guard let endDate = item.endDate else { return false }
            return endDate < Date()
        }.count
    }

    // MARK: - Body

    /// 화면 본문입니다.
    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                VStack(spacing: 14) {
                    headerCard
                    addTodoField
                    completedArchiveCard
                    listCard
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            .overlay(alignment: .bottom) {
                // 최근 삭제 1건 복구 토스트
                if let toast = viewModel.undoToast {
                    undoToast(toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
            }
            .overlay {
                if isAddTodoPopupPresented {
                    addTodoPopup
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .overlay {
                if isEditTodoPopupPresented {
                    editTodoPopup
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .todoNavigationBarInline()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Todo")
                            .font(.title3.weight(.bold))
                            .todoRoundedFontDesign()
                        Text("오늘 할 일")
                            .font(.caption.weight(.semibold))
                            .todoRoundedFontDesign()
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Todo, 오늘 할 일")
                }

                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("설정")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isReorderMode ? "완료" : "정렬") {
                        TodoHaptics.selection()
                        isReorderMode.toggle()
                    }
                    .font(.subheadline.weight(.bold))
                    .todoRoundedFontDesign()
                    .accessibilityLabel(isReorderMode ? "정렬 모드 종료" : "정렬 모드 시작")
                }
            }
            // 토스트 표시/숨김 애니메이션
            .animation(.spring(response: 0.28, dampingFraction: 0.92), value: viewModel.undoToast)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isAddTodoPopupPresented)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isEditTodoPopupPresented)
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: completingTodoIDs)
            .animation(.easeInOut(duration: 0.2), value: highlightedTodoID)
            .onReceive(notificationSelectionCenter.$selectedTodoID.compactMap { $0 }) { selectedTodoID in
                highlightTodoForNotification(selectedTodoID)
                notificationSelectionCenter.clearSelection()
            }
            .onAppear {
                // 앱이 알림 탭으로 열렸고 이벤트가 이미 들어와 있으면 최초 진입 시에도 처리합니다.
                if let selectedTodoID = notificationSelectionCenter.selectedTodoID {
                    highlightTodoForNotification(selectedTodoID)
                    notificationSelectionCenter.clearSelection()
                }
            }
            .onDisappear {
                clearHighlightedTodoTask?.cancel()
            }
            .alert("알림 권한이 꺼져 있어요", isPresented: $isReminderPermissionAlertPresented) {
                Button("설정 열기") {
                    openAppSettings()
                }
                Button(reminderPermissionFallbackButtonTitle) {
                    saveWithoutReminderForAlertMode()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("설정에서 Todo 알림을 허용하거나, 이번 항목은 알림 없이 저장할 수 있어요.")
            }
        }
    }

    // MARK: - View Sections

    // 배경 레이어
    private var backgroundLayer: some View {
        TodoTheme.backgroundGradient.ignoresSafeArea()
    }

    // 상단 요약 카드
    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Todo")
                    .font(.subheadline.weight(.semibold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.secondary)

                Text("\(inProgressCount) 진행중 · \(completedCount) 완료")
                    .font(.title2.weight(.black))
                    .todoRoundedFontDesign()

                if overdueCount > 0 {
                    Text("마감 지남 \(overdueCount)개")
                        .font(.caption.weight(.bold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(.red)
                }
            }
            Spacer()
        }
        .padding(16)
        .todoCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("진행 요약")
        .accessibilityValue("진행중 \(inProgressCount)개, 완료 \(completedCount)개, 전체 \(totalCount)개")
    }

    // 팝업 호출용 추가 버튼
    private var addTodoField: some View {
        Button {
            TodoHaptics.selection()
            isAddTodoPopupPresented = true
            isPopupInputFocused = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.blue)

                Text("할 일 추가")
                    .font(.headline.weight(.semibold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.primary)

                Spacer()
            }
            // 카드 전체를 버튼 라벨 프레임으로 확장해 탭 가능 영역을 넓힙니다.
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.9))
            )
        }
        .buttonStyle(TodoPressableButtonStyle())
        .accessibilityLabel("할 일 추가")
        .accessibilityHint("커스텀 팝업을 열어 새 할 일을 입력합니다.")
    }

    // 완료 목록 이동 카드
    private var completedArchiveCard: some View {
        NavigationLink {
            CompletedTodoListView(viewModel: viewModel)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.green.opacity(0.16))
                        .frame(width: 44, height: 44)

                    Image(systemName: "checkmark.circle.badge.clock")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.green)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("완료한 일 보기")
                        .font(.headline.weight(.bold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(.primary)

                    Text("완료 목록 \(completedCount)개")
                        .font(.subheadline.weight(.semibold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.9))
            )
        }
        .buttonStyle(TodoPressableButtonStyle())
        .accessibilityLabel("완료한 일 보기")
        .accessibilityHint("완료된 할 일 목록 화면으로 이동합니다.")
    }

    /// 새 TODO를 입력하는 커스텀 팝업입니다.
    private var addTodoPopup: some View {
        TodoEditorPopupView(
            title: "할 일 추가",
            placeholder: "할 일을 입력하세요",
            confirmTitle: "추가",
            textFieldAccessibilityLabel: "할 일 입력",
            text: $draftTitle,
            hasEndDate: $draftHasEndDate,
            endDate: $draftEndDate,
            reminderOffsets: $draftReminderOffsets,
            focusBinding: $isPopupInputFocused,
            onCancel: closeAddPopup,
            onConfirm: addTodo
        )
    }

    // TODO 수정 팝업
    /// 기존 TODO를 수정하는 커스텀 팝업입니다.
    private var editTodoPopup: some View {
        TodoEditorPopupView(
            title: "할 일 수정",
            placeholder: "할 일을 입력하세요",
            confirmTitle: "저장",
            textFieldAccessibilityLabel: "수정할 할 일 입력",
            text: $editDraftTitle,
            hasEndDate: $editHasEndDate,
            endDate: $editEndDate,
            reminderOffsets: $editReminderOffsets,
            focusBinding: $isPopupInputFocused,
            onCancel: closeEditPopup,
            onConfirm: updateTodo
        )
    }

    // 목록 영역
    @ViewBuilder
    private var listCard: some View {
        if viewModel.inProgressItems.isEmpty {
            // 빈 상태 화면
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.cyan)

                Text("진행중인 할 일이 없습니다")
                    .font(.title3.weight(.bold))
                    .todoRoundedFontDesign()

                Text("새 할 일을 추가하거나 완료 목록을 확인해보세요.")
                    .font(.footnote.weight(.medium))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .todoCardStyle()
            .accessibilityElement(children: .combine)
            .accessibilityLabel("할 일이 없습니다. 새 할 일을 추가해보세요.")
        } else {
            // 실제 TODO 목록
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.inProgressItems) { item in
                        todoRow(item)
                            .id(item.id)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if isReorderMode == false {
                                    Button(role: .destructive) {
                                        TodoHaptics.warning()
                                        viewModel.deleteTodo(id: item.id)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                    }
                    // iOS 기본 이동 로직으로 순서를 변경하고 저장합니다.
                    .onMove(perform: viewModel.moveTodos)
                }
                .task(id: pendingScrollTodoID) {
                    guard let targetID = pendingScrollTodoID else { return }
                    withAnimation(.easeInOut(duration: 0.28)) {
                        proxy.scrollTo(targetID, anchor: .center)
                    }
                    pendingScrollTodoID = nil
                }
            }
            // 정렬 핸들을 항상 노출해 바로 드래그 가능하게 합니다.
            .todoEditMode(active: isReorderMode)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .todoCardStyle()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    // TODO 행
    private func todoRow(_ item: TodoItemViewData) -> some View {
        let isCompleting = completingTodoIDs.contains(item.id)
        let isHighlighted = highlightedTodoID == item.id
        let isOverdue = {
            guard let endDate = item.endDate else { return false }
            return endDate < Date()
        }()

        return HStack(spacing: 12) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(item.isCompleted ? .green : .gray)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.weight(.semibold))
                    .todoRoundedFontDesign()
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(.primary)

                Text(item.isCompleted ? "완료됨" : "진행 중")
                    .font(.caption.weight(.bold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(item.isCompleted ? .green : .orange)

                if let endDate = item.endDate {
                    Text("마감 \(DateDisplay.todoDateTime.string(from: endDate))")
                        .font(.caption2.weight(.semibold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(isOverdue ? .red : .secondary)
                }
            }

            Spacer()

            if isOverdue {
                Text("지남")
                    .font(.caption2.weight(.bold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.red.opacity(0.9))
                    )
                    .accessibilityHidden(true)
            }

            if isReorderMode == false {
                Button {
                    beginEdit(for: item)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                        )
                }
                .buttonStyle(TodoPressableButtonStyle())
                .accessibilityLabel("\(item.title) 수정")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            completeTodoWithFeedback(item)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHighlighted ? Color.yellow.opacity(0.2) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isHighlighted ? Color.yellow.opacity(0.55) : Color.clear, lineWidth: 1)
                )
        )
        // 완료 전환 중에는 축소/페이드로 "사라지는" 느낌을 줍니다.
        .scaleEffect(isCompleting ? 0.96 : 1.0)
        .opacity(isCompleting ? 0.38 : 1.0)
        .overlay(alignment: .leading) {
            if isCompleting {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.green)
                    .padding(.leading, 1)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.isCompleted ? "완료됨" : "진행 중")
        .accessibilityHint("두 번 탭하여 완료 상태를 변경합니다.")
    }

    // 하단 삭제 복구 토스트
    private func undoToast(_ toast: UndoToastState) -> some View {
        HStack(spacing: 10) {
            Text(toast.message)
                .font(.subheadline.weight(.semibold))
                .todoRoundedFontDesign()
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 8)

            Button("취소") {
                TodoHaptics.success()
                viewModel.undoLastDeletion()
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
        .accessibilityHint("취소 버튼을 누르면 삭제를 되돌립니다.")
    }

    // MARK: - Add / Edit Actions

    // 입력값으로 TODO 추가 + 입력창 초기화
    /// 팝업 입력값으로 TODO 추가를 시작합니다.
    private func addTodo() {
        Task {
            await handleAddTodo()
        }
    }

    // 팝업 상태를 공통으로 정리합니다.
    private func closeAddPopup() {
        draftTitle = ""
        draftHasEndDate = false
        draftEndDate = Date()
        draftReminderOffsets = []
        isAddTodoPopupPresented = false
        isPopupInputFocused = false
    }

    // 수정 팝업 진입 시 대상 항목/입력값을 설정합니다.
    private func beginEdit(for item: TodoItemViewData) {
        TodoHaptics.selection()
        editingTodoID = item.id
        editDraftTitle = item.title
        editHasEndDate = item.endDate != nil
        editEndDate = item.endDate ?? Date()
        editReminderOffsets = item.reminderOffsets
        isEditTodoPopupPresented = true
        isPopupInputFocused = true
    }

    // 수정 입력값으로 TODO 제목을 갱신합니다.
    /// 팝업 입력값으로 TODO 수정을 시작합니다.
    private func updateTodo() {
        Task {
            await handleUpdateTodo()
        }
    }

    // 수정 팝업 상태를 공통으로 정리합니다.
    private func closeEditPopup() {
        editDraftTitle = ""
        editHasEndDate = false
        editEndDate = Date()
        editReminderOffsets = []
        editingTodoID = nil
        isEditTodoPopupPresented = false
        isPopupInputFocused = false
    }

    // MARK: - Completion Interaction

    // 진행중 TODO를 완료 처리할 때 인터랙션 효과를 먼저 노출한 뒤 상태를 전환합니다.
    /// 진행중 TODO를 완료 처리할 때 시각/촉각 피드백을 함께 적용합니다.
    /// - Parameter item: 완료 처리 대상 항목입니다.
    private func completeTodoWithFeedback(_ item: TodoItemViewData) {
        // 진행중 항목이 아니거나 이미 애니메이션 중이면 중복 처리를 막습니다.
        guard item.isCompleted == false else { return }
        guard completingTodoIDs.contains(item.id) == false else { return }

        _ = withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
            completingTodoIDs.insert(item.id)
        }

        // 완료 시점 촉각 피드백으로 인터랙션 감각을 강화합니다.
        TodoHaptics.lightImpact()

        Task {
            // 짧은 지연으로 시각 효과를 먼저 보여준 뒤 실제 완료 상태를 반영합니다.
            try? await Task.sleep(nanoseconds: 180_000_000)
            await viewModel.toggleCompletion(for: item.id)

            _ = withAnimation(.easeOut(duration: 0.2)) {
                completingTodoIDs.remove(item.id)
            }
        }
    }

    // MARK: - Permission Handling

    // 추가 동작에서 알림 권한 상태를 검사한 뒤 저장을 수행합니다.
    @MainActor
    private func handleAddTodo() async {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        let selectedReminderOffsets = draftHasEndDate ? draftReminderOffsets : []
        let permissionStatus = await viewModel.reminderPermissionStatusIfNeeded(reminderOffsets: selectedReminderOffsets)

        if permissionStatus == .denied, selectedReminderOffsets.isEmpty == false {
            reminderPermissionAlertMode = .add
            isReminderPermissionAlertPresented = true
            return
        }

        performAddTodo(reminderOffsets: selectedReminderOffsets)
    }

    // 수정 동작에서 알림 권한 상태를 검사한 뒤 저장을 수행합니다.
    @MainActor
    private func handleUpdateTodo() async {
        let trimmed = editDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        guard editingTodoID != nil else { return }

        let selectedReminderOffsets = editHasEndDate ? editReminderOffsets : []
        let permissionStatus = await viewModel.reminderPermissionStatusIfNeeded(reminderOffsets: selectedReminderOffsets)

        if permissionStatus == .denied, selectedReminderOffsets.isEmpty == false {
            reminderPermissionAlertMode = .edit
            isReminderPermissionAlertPresented = true
            return
        }

        performUpdateTodo(reminderOffsets: selectedReminderOffsets)
    }

    // 추가 저장 로직(권한 검사 통과 후)을 실행합니다.
    private func performAddTodo(reminderOffsets: [Int]) {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        TodoHaptics.success()
        viewModel.addTodo(
            title: trimmed,
            endDate: draftHasEndDate ? draftEndDate : nil,
            reminderOffsets: reminderOffsets
        )
        closeAddPopup()
    }

    // 수정 저장 로직(권한 검사 통과 후)을 실행합니다.
    private func performUpdateTodo(reminderOffsets: [Int]) {
        let trimmed = editDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        guard let editingTodoID else { return }

        TodoHaptics.success()
        viewModel.updateTodo(
            id: editingTodoID,
            title: trimmed,
            endDate: editHasEndDate ? editEndDate : nil,
            reminderOffsets: reminderOffsets
        )
        closeEditPopup()
    }

    // MARK: - Alert / Settings / Notification Highlight

    // 권한 거부 알럿에서 \"알림 없이 저장\"을 선택했을 때 현재 액션을 이어서 저장합니다.
    /// 권한 거부 알럿에서 "알림 없이 저장"을 선택했을 때 현재 액션(추가/수정)을 수행합니다.
    private func saveWithoutReminderForAlertMode() {
        switch reminderPermissionAlertMode {
        case .add:
            performAddTodo(reminderOffsets: [])
        case .edit:
            performUpdateTodo(reminderOffsets: [])
        }
    }

    // 알럿 모드에 맞는 \"알림 없이\" 버튼 타이틀입니다.
    private var reminderPermissionFallbackButtonTitle: String {
        switch reminderPermissionAlertMode {
        case .add:
            return "알림 없이 추가"
        case .edit:
            return "알림 없이 저장"
        }
    }

    // 앱 설정 화면을 열어 사용자가 알림 권한을 직접 변경할 수 있게 합니다.
    /// 시스템 앱 설정 화면을 엽니다.
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // 알림 탭으로 전달된 TODO ID를 일정 시간 강조 표시합니다.
    /// 알림 탭으로 진입한 TODO를 강조하고 목록 중앙으로 스크롤합니다.
    /// - Parameter todoID: 강조 대상 TODO ID입니다.
    private func highlightTodoForNotification(_ todoID: Int) {
        guard viewModel.inProgressItems.contains(where: { $0.id == todoID }) else { return }

        clearHighlightedTodoTask?.cancel()
        highlightedTodoID = todoID
        pendingScrollTodoID = todoID

        clearHighlightedTodoTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard Task.isCancelled == false else { return }
            await MainActor.run {
                if highlightedTodoID == todoID {
                    highlightedTodoID = nil
                }
            }
        }
    }
}

// 알림 권한 안내 알럿에서 현재 동작 컨텍스트를 구분합니다.
private enum ReminderPermissionAlertMode {
    case add
    case edit
}

@MainActor
/// 메인 TODO 화면 프리뷰입니다.
struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView(viewModel: makePreviewViewModel())
            .previewDisplayName("TodoList")
            .preferredColorScheme(.light)
    }

    // 프리뷰용 샘플 데이터
    private static func makePreviewViewModel() -> TodoListViewModel {
        TodoListViewModel(
            initialItems: [
                TodoItemViewData(id: 1, title: "마트 들르기", isCompleted: false),
                TodoItemViewData(id: 2, title: "세탁기 돌리기", isCompleted: true, completedAt: Date()),
                TodoItemViewData(id: 3, title: "회의 준비하기", isCompleted: false),
                TodoItemViewData(id: -1, title: "내가 추가한 할 일", isCompleted: false),
                TodoItemViewData(id: -2, title: "완료한 보고서 제출", isCompleted: true, completedAt: Date())
            ],
            store: InMemoryTodoStore()
        )
    }
}
