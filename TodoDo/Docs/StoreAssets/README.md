# App Store Screenshot Set (TodoDo)

이 폴더는 `TodoDo` 앱의 App Store Connect 업로드용 iPhone 스크린샷 세트입니다.
이번 세트는 **실제 시뮬레이터에서 앱 화면을 캡처**한 이미지를 기준으로 구성했습니다.

## 생성 결과

- `output/iphone-6.9/`: 1320 x 2868, 5장
- `output/iphone-6.5/`: 1242 x 2688, 5장
- `output/iphone-5.5/`: 1242 x 2208, 5장

파일명 규칙:

- `screenshot-01.png`
- `screenshot-02.png`
- `screenshot-03.png`
- `screenshot-04.png`
- `screenshot-05.png`

## 구성 방식

- `output_raw`: 실제 앱 화면 원본 캡처본
- `output`: App Store 소개형 최종본(상단 문구 + 하단 앱 프리뷰)

## 소개형 이미지 재생성 방법

```bash
swiftc -module-cache-path /tmp/swift-module-cache \
  /Users/kimkyeongbeom/Desktop/testprjt/TodoDo/Docs/StoreAssets/generate_marketing_store_images.swift \
  -o /tmp/generate_marketing_store_images && /tmp/generate_marketing_store_images
```

## Apple 심사 지침 대응 체크

- 실제 앱 화면(메인/추가 팝업/완료 목록/수정 팝업/설정) 기준 구성
- 과장형 성능 주장(예: "최고", "1위", "무료 보장") 미사용
- 타 플랫폼/타사 브랜드 로고 미사용
- 성인/선정/오해 유발 요소 미포함

## 업로드 전 권장 확인

- 앱 최신 빌드 기준으로 화면/문구가 실제 동작과 일치하는지 확인
- 한국어/영어 메타데이터 로컬라이징과 톤 일관성 확인

## 문구 가이드

- 스크린샷/메타데이터 문구 초안: `/Users/kimkyeongbeom/Desktop/testprjt/TodoDo/Docs/StoreAssets/STORE_COPY_KO.md`
