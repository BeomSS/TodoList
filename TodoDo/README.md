# 투두두

SwiftUI + MVVM 기반의 로컬 TODO 앱입니다.
저장소는 `CoreData`를 사용합니다.

## 최소 iOS 버전
- iOS 16.0

## 현재 구조
- `App`: 앱 진입점과 의존성 조립
- `Presentation/TodoList`: View, ViewModel
- `Domain/Todo`: 서비스/UseCase(비즈니스 로직)
- `Data`: 저장소/알림/위젯 스냅샷/분석 구현
- `Shared`: 앱-위젯 공유 모델/설정
- `TodoDoTests`: ViewModel/Service/UseCase 테스트

## 폴더 구조

```text
TodoDo/
  App/
    TodoDo.swift
    AppDIContainer.swift
    TodoAppDelegate.swift
    TodoNotificationSelectionCenter.swift
  Domain/
    Todo/
      FetchTodoListUseCase.swift
      AddTodoUseCase.swift
      ...
      DefaultFetchTodoListUseCase.swift
      DefaultAddTodoUseCase.swift
      ...
      LocalTodoService.swift
      TodoReminderScheduling.swift
      TodoReminderPermissionStatus.swift
      TodoReminderPermissionChecking.swift
  Data/
    Persistence/
      LocalTodoPersistedState.swift
      TodoStore.swift
      InMemoryTodoStore.swift
      CoreDataTodoStore.swift
    Notifications/
      LocalNotificationPermissionChecker.swift
      LocalNotificationTodoReminderScheduler.swift
    Widget/
      TodayTodoWidgetSnapshotWriting.swift
      TodayTodoWidgetSnapshotStore.swift
    Analytics/
      TodoEventLoggerPublisher.swift
  Presentation/
    TodoList/
      TodoItemViewData.swift
      UndoToastState.swift
      CompletedTodoListView.swift
      TodoListView.swift
      TodoListViewModel.swift
      TodoTheme.swift
      TodoReminderOption.swift
      View+TodoModifiers.swift
      SettingsView.swift
  Shared/
    AppGroupConfig.swift
    TodayTodoWidgetConfig.swift
    SharedTodayTodoWidgetSnapshot.swift
    SharedTodayTodoWidgetItem.swift
TodayTodoWidget/
  TodayTodoWidget.swift
  TodayTodoEntry.swift
  TodayTodoEntryItem.swift
  TodayTodoProvider.swift
  TodayTodoWidgetView.swift
  TodayTodoWidgetHeaderView.swift
  TodayTodoWidgetEmptyStateView.swift
  TodayTodoWidgetItemRowView.swift
  TodayWidgetBackgroundModifier.swift
TodoDoTests/
  TodoListViewModelTests.swift
```

## 품질 문서
- `Docs/TESTING_STRATEGY.md`: 커버리지 기준선, 테스트 작성 규칙, 템플릿
- `Docs/RELEASE_CHECKLIST.md`: 앱 배포 전 확인 항목

## 확장 포인트
- `TodoEventPublishing`: TODO 도메인 이벤트(추가/수정/삭제/정렬/전체삭제) 발행 지점
- `TodoListPartitioning`: 화면별 목록 분리/정렬 전략 주입 지점
- `TodayTodoWidgetSnapshotWriting`: 위젯 스냅샷 저장 매체 교체 지점

## 주요 기능
- 할 일 추가/삭제
- 완료 체크/해제
- 완료 목록 분리(메인 화면은 진행중만 표시)
- 완료 목록 전용 화면 제공
- 스와이프 삭제 후 1건 복구(토스트)
- 커스텀 추가 팝업
- Siri/단축어로 음성 TODO 추가
- VoiceOver/Dynamic Type 대응 접근성 개선

## Siri 사용 예시
- "시리야. 투두두에서 우유 사기 추가해줘."
- "시리야. 투두두에서 빨래 하기 오늘 3시까지로 추가해줘."
- "시리야. 투두두에서 이불빨래 하기 3월 18일 오후 6시까지로 추가해줘."

앱은 발화 텍스트에서 날짜를 자동 인식해 마감일로 저장하고, 날짜를 제외한 나머지 문장을 제목으로 저장합니다.

## 실행 방법
1. `/Users/kimkyeongbeom/Desktop/testprjt/TodoDo.xcodeproj`를 엽니다.
2. iOS 16+ 시뮬레이터를 선택합니다.
3. `TodoDo` 스킴으로 실행합니다.
