# Release Checklist

## 1. Build & Test
- [ ] `swift test` 통과
- [ ] `xcodebuild` iOS 빌드 성공 (`CODE_SIGNING_ALLOWED=NO`)
- [ ] 핵심 시나리오 수동 점검 완료

## 2. Functionality
- [ ] TODO 추가/삭제/복구 동작 확인
- [ ] 완료 체크/해제 및 1주 자동삭제 정책 확인
- [ ] 앱 재실행 후 데이터 유지 확인(CoreData)

## 3. Accessibility
- [ ] Dynamic Type에서 레이아웃 깨짐 없음
- [ ] VoiceOver 라벨/힌트 확인
- [ ] 색 대비(텍스트/배경) 점검

## 4. Stability
- [ ] 크래시 로그/런타임 경고 확인
- [ ] 메모리 누수(기본 플로우) 점검
- [ ] 백그라운드/포그라운드 전환 시 상태 이상 없음

## 5. Privacy & Policy
- [ ] 불필요한 권한 요청 없음
- [ ] 민감 데이터 저장/전송 없음(또는 정책 반영)
- [ ] 앱 설명/스크린샷/메타데이터 최신화

## 6. App Store Readiness
- [ ] 버전/빌드 번호 업데이트
- [ ] 릴리즈 노트 작성
- [ ] 배포 서명/프로비저닝 설정 확인
- [ ] TestFlight 최종 smoke test 완료
