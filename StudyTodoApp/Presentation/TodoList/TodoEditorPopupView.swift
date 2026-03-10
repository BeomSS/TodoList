import SwiftUI

/// 할 일 추가/수정에서 공통으로 사용하는 커스텀 팝업입니다.
struct TodoEditorPopupView: View {
    // MARK: - Inputs

    // 상단 제목입니다. 예: "할 일 추가", "할 일 수정".
    let title: String
    // 입력 플레이스홀더입니다.
    let placeholder: String
    // 확인 버튼 문구입니다. 예: "추가", "저장".
    let confirmTitle: String
    // 입력 필드 접근성 레이블입니다.
    let textFieldAccessibilityLabel: String
    // 현재 입력값 바인딩입니다.
    @Binding var text: String
    // 마감일 사용 여부 바인딩입니다.
    @Binding var hasEndDate: Bool
    // 마감일 값 바인딩입니다.
    @Binding var endDate: Date
    // 선택된 알림 오프셋(초) 목록 바인딩입니다.
    @Binding var reminderOffsets: [Int]
    // 팝업 입력 포커스 바인딩입니다.
    let focusBinding: FocusState<Bool>.Binding
    // 취소 버튼 동작입니다.
    let onCancel: () -> Void
    // 확인 버튼 동작입니다.
    let onConfirm: () -> Void

    // MARK: - Derived Values

    // 확인 버튼 활성화 여부입니다.
    private var canConfirm: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    // 알림 칩 선택 여부 조회용 Set입니다.
    private var reminderOffsetSet: Set<Int> {
        Set(reminderOffsets)
    }

    // MARK: - Body

    /// 팝업 본문입니다.
    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .todoRoundedFontDesign()

                TextField(placeholder, text: $text)
                    .font(.body.weight(.semibold))
                    .todoRoundedFontDesign()
                    .todoTextFieldInputStyle()
                    .focused(focusBinding)
                    .onSubmit {
                        onConfirm()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(TodoTheme.popupInputBackgroundColor)
                    )
                    .accessibilityLabel(textFieldAccessibilityLabel)

                Toggle(isOn: $hasEndDate) {
                    Text("마감일 설정")
                        .font(.footnote.weight(.semibold))
                        .todoRoundedFontDesign()
                }
                .toggleStyle(.switch)

                if hasEndDate {
                    DatePicker(
                        "마감일",
                        selection: $endDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .font(.footnote.weight(.semibold))
                    .todoRoundedFontDesign()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("알림")
                        .font(.footnote.weight(.bold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(.secondary)

                    if hasEndDate {
                        reminderOptionGrid

                        Text(reminderOffsets.isEmpty ? "알림 없음" : "선택된 알림 \(reminderOffsets.count)개")
                            .font(.caption2.weight(.semibold))
                            .todoRoundedFontDesign()
                            .foregroundStyle(.secondary)
                    } else {
                        Text("마감일을 설정하면 알림 시간을 선택할 수 있어요.")
                            .font(.caption.weight(.semibold))
                            .todoRoundedFontDesign()
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 10) {
                    Button("취소") {
                        TodoHaptics.selection()
                        onCancel()
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

                    Button(confirmTitle) {
                        onConfirm()
                    }
                    .font(.body.weight(.bold))
                    .todoRoundedFontDesign()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(canConfirm ? Color.blue : Color.gray)
                    )
                    .disabled(canConfirm == false)
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
        .onAppear {
            // 팝업 애니메이션 직후 포커스를 적용해 키보드 전환을 안정화합니다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusBinding.wrappedValue = true
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Reminder Options

    /// 애플 캘린더와 유사하게 여러 알림 시점을 칩 형태로 선택합니다.
    private var reminderOptionGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 8)], spacing: 8) {
            ForEach(TodoReminderOption.allCases) { option in
                let isSelected = reminderOffsetSet.contains(option.rawValue)

                Button {
                    toggleReminderOffset(option.rawValue)
                } label: {
                    Text(option.title)
                        .font(.caption.weight(.semibold))
                        .todoRoundedFontDesign()
                        .foregroundStyle(isSelected ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? Color.blue : Color.gray.opacity(0.14))
                        )
                }
                .buttonStyle(TodoPressableButtonStyle())
            }
        }
    }

    /// 알림 오프셋 선택/해제를 토글합니다.
    /// - Parameter offset: 선택/해제할 오프셋(초) 값입니다.
    private func toggleReminderOffset(_ offset: Int) {
        var current = Set(reminderOffsets)
        if current.contains(offset) {
            current.remove(offset)
        } else {
            current.insert(offset)
        }
        reminderOffsets = Array(current).sorted()
    }
}
