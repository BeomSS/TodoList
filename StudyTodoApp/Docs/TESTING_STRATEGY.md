# Testing Strategy

## Goal
- 기능 확장 시 회귀를 빠르게 탐지하고, 릴리즈 전 품질을 정량적으로 확인합니다.

## Coverage Baseline
- 최소 라인 커버리지: 70%
- 권장 라인 커버리지: 80%+
- 핵심 계층 목표:
  - Domain: 90%+
  - Data/Persistence: 80%+
  - Presentation/ViewModel: 80%+

## Required Test Scope Per Feature
- 신규 기능 추가 시 아래 테스트를 함께 추가합니다.
  - 1. 정상 흐름(happy path) 테스트
  - 2. 경계값/빈값 테스트
  - 3. 상태 전이 테스트(추가/수정/삭제/복구)
  - 4. 영속성 반영 테스트(저장 후 재조회)

## Naming Convention
- 테스트 메서드 이름 규칙:
  - `test_<condition>_<expectedBehavior>()`
- 예시:
  - `test_addTodo_withWhitespaceOnly_ignoresInput()`
  - `test_toggleCompletion_whenCompleted_setsCompletedAt()`

## Test Template
```swift
import XCTest
@testable import StudyTodoApp

final class FeatureNameTests: XCTestCase {
    // GIVEN: 테스트 준비
    // WHEN: 동작 수행
    // THEN: 기대 결과 검증
    func test_condition_expectedBehavior() {
        // Given
        let sut = /* System Under Test */

        // When
        /* action */

        // Then
        XCTAssertEqual(/* actual */, /* expected */)
    }
}
```

## CI Recommendation
- Pull Request마다 아래 순서로 실행합니다.
  - 1. `swift test`
  - 2. `xcodebuild` iOS build (`CODE_SIGNING_ALLOWED=NO`)
- 릴리즈 브랜치에서는 커버리지 리포트 생성을 추가합니다.
