# Spotter

스포터(Spotter)는 운동 트래킹과 관리를 위한 iOS 애플리케이션으로, 다이나믹 아일랜드와 LiveActivity를 활용한 실시간 운동 세션 모니터링 기능을 제공합니다.

## 개요

스포터 앱은 사용자가 운동 루틴을 계획하고, 운동 세션을 추적하며, 휴식 시간을 관리할 수 있도록 설계되었습니다. 특히 iOS의 LiveActivity 기능을 활용하여 앱을 활성화하지 않고도 운동 진행 상황과 휴식 시간을 실시간으로 모니터링할 수 있습니다.

## 주요 기능

### 운동 템플릿 관리
- 운동 템플릿 생성, 수정, 삭제
- 운동 항목 추가/제거
- 템플릿 공유 및 가져오기 (QR 코드, 링크)

### 운동 세션 관리
- 템플릿 기반 운동 세션 시작
- 세트 추적 및 완료 상태 관리
- 실시간 진행 상황 표시
- 자동 휴식 타이머

### 다이나믹 아일랜드 기능
- **운동 모드**: 현재 운동 정보, 세트 진행 상황, 총 진행률 표시
- **휴식 타이머 모드**: 카운트다운 타이머, 다음 운동 정보 표시
- 모드 간 부드러운 전환 애니메이션
- 확장 뷰로 추가 상호작용 제공

### 운동 기록 및 분석
- 완료된 운동 세션 기록
- 날짜별/템플릿별 필터링
- 통계 그래프 및 추세 분석
- 데이터 내보내기 (CSV/JSON)

### 사용자 설정
- 다크/라이트 모드 지원
- 알림 설정
- 휴식 타이머 기본값 설정
- 무게 단위(kg/lb) 설정

## 추가 기능

### Apple Watch 통합
- Watch 앱을 통한 독립적 운동 추적
- 심박수 모니터링 및 햅틱 피드백
- iOS 앱과 실시간 동기화

### 건강 앱 통합
- HealthKit으로 운동 데이터 자동 내보내기
- 신체 정보 및 운동 데이터 가져오기
- 활동 통계와 칼로리 소모량 연동

### 데이터 동기화 및 백업
- iCloud를 통한 기기 간 데이터 동기화
- 자동/수동 백업 및 복원 기능
- 데이터 암호화 지원

### AI 기반 추천 시스템
- 운동 데이터 분석 기반 개인화된 템플릿 추천
- 진행 상황에 맞춘 무게/세트 제안
- 패턴 인식을 통한 자동 운동 카운팅

### 고급 분석 기능
- 볼륨, 강도, 빈도 추세 분석
- 근육 그룹별 트레이닝 균형 분석
- 목표 달성 예측 및 추적

### 소셜 및 커뮤니티 기능
- 템플릿 공유 플랫폼
- 친구와 운동 진행 상황 공유
- 운동 도전 과제 및 성취 배지 시스템

### 고급 타이머 옵션
- HIIT, 태버타, EMOM 등 특수 타이밍 프로토콜
- 다양한 운동 유형별 맞춤 템플릿
- 서킷 트레이닝 지원

### 접근성 지원
- 완전한 VoiceOver 호환성
- 음성 명령을 통한 세트 완료 및 타이머 제어
- 다양한 접근성 설정 지원

## 기술 스택

- **언어**: Swift
- **플랫폼**: iOS
- **UI 프레임워크**: SwiftUI
- **데이터 관리**: SwiftData
- **비동기 처리**: Combine, Swift Concurrency (async/await)
- **기타**: ActivityKit (LiveActivity), NotificationCenter, AppStorage

## 아키텍처

스포터 앱은 클린 아키텍처 원칙을 기반으로 설계되었으며, MVVM(Model-View-ViewModel) 패턴을 주로 사용합니다.

### 아키텍처 계층
- **도메인 계층**: 비즈니스 로직과 모델 정의
- **데이터 계층**: 데이터 저장 및 관리
- **프레젠테이션 계층**: 사용자 인터페이스와 상호작용
- **코어 계층**: 공통 서비스와 유틸리티

### 주요 서비스
- **LiveActivityService**: 다이나믹 아일랜드 관리
- **WorkoutSessionManager**: 운동 세션 상태 관리
- **TimerService**: 휴식 타이머 관리
- **SwiftDataManager**: 데이터 영속성 관리

## 스크린샷 및 UI

(여기에 앱 스크린샷 추가)

## 폴더 구조

```
Spotter/
├── App/                    # 앱 진입점 및 초기화
│   ├── SpotterApp.swift    # 앱 진입점
│   ├── AppDelegate.swift   # 앱 델리게이트
│   └── MainTabView.swift   # 메인 탭 네비게이션
│
├── Core/                   # 핵심 기능 및 서비스
│   ├── LiveActivity/       # 실시간 활동 관련 기능
│   ├── SwiftData/          # SwiftData 관리
│   ├── AppState/           # 앱 상태 관리
│   ├── Theme/              # 테마 관리
│   ├── Timer/              # 타이머 관련 기능
│   ├── Logging/            # 로그 관리
│   ├── Auth/               # 인증 관련 기능
│   └── Extensions/         # 핵심 기능 확장
│
├── Domain/                 # 도메인 계층
│   ├── Models/             # 도메인 모델
│   ├── UseCases/           # 비즈니스 로직
│   └── Repositories/       # 데이터 액세스 추상화
│
├── Data/                   # 데이터 계층
│   ├── Repositories/       # 리포지토리 구현
│   └── DataSources/        # 데이터 소스
│
├── Services/               # 앱 서비스
│
├── Presentation/           # 프레젠테이션 계층
│   ├── Common/             # 공통 UI 요소
│   └── Features/           # 기능별 UI 요소
│
├── Views/                  # 화면 및 뷰
│   ├── ActiveWorkout/      # 활성 운동 화면
│   ├── HistoryTab/         # 운동 기록 화면
│   ├── StartTab/           # 시작 탭 화면
│   ├── SettingTab/         # 설정 탭 화면
│   └── Components/         # 재사용 가능한 컴포넌트
│
├── ViewModels/             # 뷰 모델
│
├── Utils/                  # 유틸리티 함수
│
├── Extensions/             # 확장 함수
│
├── Resources/              # 리소스 파일
│
└── Assets.xcassets/        # 이미지 및 색상 에셋
```

## 다이나믹 아일랜드 세부 구현

### 운동 모드와 휴식 모드
다이나믹 아일랜드는 두 가지 주요 모드 간에 전환됩니다:

#### 운동 모드
- 현재 운동 이름, 세트 정보, 진행률 표시
- 사용자 상호작용으로 확장 뷰 제공
- 세트 완료시 자동 업데이트

#### 휴식 타이머 모드
- 카운트다운 타이머와 진행 표시기
- 다음 운동 정보 표시
- 1초마다 업데이트

### 모드 전환 로직

```swift
// 휴식 모드로 전환
func switchToRestTimerMode(remainingSeconds: Int, nextExerciseName: String) async {
    // 페이드 애니메이션으로 부드러운 전환
    var contentState = activity?.contentState
    contentState?.activityMode = .fadeInRestTimerMode
    
    await activity?.update(using: contentState)
    
    // 애니메이션 시간 대기 후 실제 데이터 업데이트
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
    
    contentState?.activityMode = .restTimerMode
    contentState?.remainingSeconds = remainingSeconds
    contentState?.totalRestSeconds = remainingSeconds
    contentState?.nextExerciseName = nextExerciseName
    
    await activity?.update(using: contentState)
    
    // 타이머 시작
    startRestTimer(seconds: remainingSeconds)
}
```

## 운동 세션 흐름

1. **세션 시작**
   - 템플릿 선택 및 세션 초기화
   - LiveActivity 활성화

2. **세트 진행**
   - 무게/반복 횟수 입력
   - 세트 완료 후 데이터 저장
   - LiveActivity 업데이트

3. **휴식 시간**
   - 카운트다운 타이머 표시
   - 1초마다 업데이트
   - 타이머 완료 시 자동 전환

4. **운동 항목 전환**
   - 모든 세트 완료 시 다음 운동으로 이동
   - UI 및 LiveActivity 업데이트

5. **세션 종료**
   - 통계 계산 및 데이터 저장
   - LiveActivity 종료

## 코드 가이드라인

### 명명 규칙
- **파일/클래스/구조체/열거형**: PascalCase (예: WorkoutSession)
- **변수/함수**: camelCase (예: startWorkout())
- **프로토콜**: PascalCase, 주로 명사/형용사 (예: WorkoutManageable)

### SwiftUI 뷰 구성
- 복잡한 뷰는 작은 컴포넌트로 분리
- 뷰 확장을 통해 서브뷰 구성
- 뷰 수정자는 가독성을 위해 새 줄에 배치

### MVVM 패턴
- **모델**: 순수 데이터 구조 및 비즈니스 로직
- **뷰**: UI 표현만 담당
- **뷰모델**: 상태 관리 및 데이터 변환

## 설치 및 실행

### 요구 사항
- iOS 16.1 이상
- Xcode 15.0 이상
- Swift 5.9 이상

### 설치 방법
1. 레포지토리 클론
   ```
   git clone https://github.com/yourusername/spotter.git
   ```
2. Xcode에서 프로젝트 열기
3. 빌드 및 실행

## 향후 개선 방향

- 사용자 간 템플릿 공유 기능 강화
- 고급 통계 분석 및 시각화
- 게임화 요소 도입
- iPad 최적화 및 watchOS 지원 확대

## 기여 방법

1. 이슈 생성 또는 기존 이슈 확인
2. 포크 및 브랜치 생성
3. 변경사항 커밋
4. 풀 리퀘스트 생성

## 라이선스

이 프로젝트는 [라이선스 이름] 라이선스에 따라 배포됩니다. 자세한 내용은 LICENSE 파일을 참조하세요.

## 연락처 및 도움말

앱 사용 중 문제가 발생하거나 피드백이 있으시면 다음 방법으로 연락해 주세요:
- 이메일: [이메일 주소]
- GitHub: [GitHub 레포지토리 주소]
- 웹사이트: [웹사이트 주소] 