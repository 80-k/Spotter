# Spotter 앱 설계 및 아키텍처 문서

## 1. 개요

Spotter는 효율적인 운동 트래킹과 관리를 위한 iOS 애플리케이션입니다. 사용자가 운동 루틴을 계획하고, 운동 세션을 추적하며, 휴식 시간을 관리할 수 있도록 설계되었습니다. 특히 실시간 활동(LiveActivity) 기능을 통해 사용자가 앱을 활성화하지 않고도 운동 진행 상황과 휴식 시간을 모니터링할 수 있는 기능을 제공합니다.

## 2. 기술 스택

- **언어**: Swift
- **플랫폼**: iOS
- **UI 프레임워크**: SwiftUI
- **데이터 관리**: SwiftData
- **비동기 처리**: Combine, Swift Concurrency (async/await)
- **기타**: ActivityKit (LiveActivity), NotificationCenter, AppStorage

## 3. 아키텍처

Spotter 앱은 클린 아키텍처 원칙을 기반으로 설계되었으며, MVVM(Model-View-ViewModel) 패턴을 주로 사용합니다. 아키텍처는 다음 주요 계층으로 구성됩니다:

### 3.1 도메인 계층 (Domain Layer)

비즈니스 로직과 모델을 포함하며, 앱의 핵심 기능을 정의합니다.

- **모델 (Models)**: 앱의 핵심 데이터 구조 정의
  - `WorkoutSession`: 운동 세션 정보
  - `WorkoutTemplate`: 운동 템플릿 정의
  - `WorkoutSet`: 각 운동 세트의 상세 정보
  - `ExerciseItem`: 개별 운동 항목 정보
  - `MuscleGroup`: 근육 그룹 정의

- **유스케이스 (UseCases)**: 비즈니스 로직 구현
  - 운동 세션 관리
  - 운동 템플릿 관리
  - 휴식 타이머 관리

- **리포지토리 (Repositories)**: 데이터 액세스 추상화

### 3.2 데이터 계층 (Data Layer)

데이터 저장 및 관리를 담당합니다.

- **SwiftData**: 모델 영속성 제공
- **SwiftDataManager**: 데이터 관리 및 스키마 정의

### 3.3 프레젠테이션 계층 (Presentation Layer)

사용자 인터페이스와 상호작용을 담당합니다.

- **Views**: SwiftUI 기반 사용자 인터페이스
  - 탭별 화면 구조 (시작, 활성 운동, 히스토리, 설정)
  - 컴포넌트 및 재사용 가능한 뷰

- **ViewModels**: 뷰 로직 및 상태 관리
  - 데이터 변환 및 포맷팅
  - 사용자 인터랙션 처리

### 3.4 코어 계층 (Core Layer)

앱 전반에 걸쳐 사용되는 공통 서비스와 유틸리티를 제공합니다.

- **LiveActivity**: 실시간 활동 관리
- **AppState**: 앱 상태 관리
- **Theme**: 테마 및 시각적 스타일 관리
- **Timer**: 타이머 로직 관리
- **Auth**: 인증 관련 기능
- **Logging**: 로깅 및 디버깅 지원

## 4. 주요 기능

### 4.1 운동 템플릿 관리

- 운동 템플릿 생성, 수정, 삭제
- 운동 항목 추가/제거
- 템플릿 공유 및 가져오기

### 4.2 운동 세션 관리

- 템플릿 기반 운동 세션 시작
- 세트 추적 및 완료 상태 관리
- 휴식 시간 관리
- 운동 통계 기록

### 4.3 휴식 타이머

- 세트 간 휴식 시간 설정 및 관리
- 타이머 알림 제공
- LiveActivity를 통한 실시간 타이머 표시

### 4.4 LiveActivity 통합

- 운동 모드와 휴식 모드 간의 원활한 전환
- 운동 진행 상황 실시간 표시
- 휴식 타이머 실시간 카운트다운
- 앱 백그라운드 상태에서도 정보 표시

### 4.5 테마 및 UI 개인화

- 다크/라이트 모드 지원
- 사용자 지정 테마 옵션
- 접근성 설정

## 5. 디자인 원칙

### 5.1 모듈성 (Modularity)

- 기능별로 명확하게 분리된 모듈 구조
- 의존성 최소화 및 의존성 주입 활용
- 인터페이스와 구현의 분리

### 5.2 확장성 (Scalability)

- 새로운 기능을 쉽게 추가할 수 있는 구조
- 프로토콜 지향 설계로 컴포넌트 교체 용이성 확보

### 5.3 유지보수성 (Maintainability)

- 일관된 코드 스타일 및 명명 규칙
- 적절한 주석 및 문서화
- 단위 테스트 지원 구조

### 5.4 성능 (Performance)

- 효율적인 데이터 액세스 패턴
- 비동기 작업 최적화
- 배터리 효율성 고려

## 6. 데이터 모델

### 6.1 핵심 모델

#### WorkoutTemplate
- 이름, 설명 등의 기본 정보
- 포함된 운동 항목 목록
- 생성 및 수정 일자

#### ExerciseItem
- 운동 이름, 설명, 유형
- 근육 그룹 지정
- 기본 무게 및 반복 횟수 설정

#### WorkoutSession
- 시작 및 종료 시간
- 총 운동 시간
- 관련 템플릿 정보
- 완료된 세트 및 총 세트 수
- 총 무게 통계

#### WorkoutSet
- 무게 및 반복 횟수
- 완료 상태
- 휴식 시간 설정
- 관련 운동 항목 정보

### 6.2 SwiftData 스키마

SwiftData는 앱의 데이터 영속성을 관리하며, 다음과 같은 모델이 정의되어 있습니다:
- ExerciseItem
- WorkoutTemplate
- WorkoutSession
- WorkoutSet

## 7. 주요 서비스

### 7.1 LiveActivityService

LiveActivity 기능을 관리하는 핵심 서비스로, 운동 모드와 휴식 타이머 모드 간의 전환을 처리합니다.

- **ActivityMode 열거형**:
  - `workoutMode`: 일반 운동 모드
  - `restTimerMode`: 휴식 타이머 모드
  - `fadeInWorkoutMode`: 휴식에서 운동 모드로 전환 중
  - `fadeInRestTimerMode`: 운동에서 휴식 모드로 전환 중

- **주요 메서드**:
  - `startWorkoutActivity`: 운동 활동 시작
  - `updateWorkoutActivity`: 운동 정보 업데이트
  - `startRestTimerActivity`: 휴식 타이머 시작
  - `updateRestTimerActivity`: 휴식 타이머 업데이트
  - `switchToWorkoutMode`: 운동 모드로 전환
  - `endActivity`: 활동 종료

### 7.2 AppStateService

앱의 전반적인 상태를 관리하는 서비스입니다.

- 현재 ScenePhase 관리
- 앱 상태 변경 이벤트 처리
- 앱 라이프사이클 관리

### 7.3 ThemeService

앱의 시각적 테마를 관리합니다.

- 다크/라이트 모드 전환
- 사용자 정의 테마 설정
- 테마 변경 이벤트 처리

### 7.4 SwiftDataManager

SwiftData 모델 컨테이너를 관리하는 서비스입니다.

- 데이터 스키마 정의
- 모델 구성 설정
- 공유 모델 컨테이너 제공

## 8. 사용자 인터페이스 구조

### 8.1 주요 화면

- **온보딩**: 앱 최초 실행 시 사용자 안내
- **인증**: 로그인 및 계정 관리
- **메인 탭 뷰**: 앱의 주요 네비게이션 구조
  - **시작 탭**: 템플릿 선택 및 세션 시작
  - **활성 운동 화면**: 현재 진행 중인 운동 관리
  - **히스토리 탭**: 과거 운동 기록 확인
  - **설정 탭**: 앱 설정 및 사용자 프로필 관리

### 8.2 컴포넌트

- 재사용 가능한 UI 컴포넌트
- 템플릿 헤더 뷰
- 운동 세트 카드
- 휴식 타이머 뷰

## 9. 동시성 및 비동기 처리

### 9.1 Swift Concurrency

- async/await를 활용한 비동기 코드 구현
- Task를 통한 비동기 작업 관리
- 적절한 에러 처리 및 취소 메커니즘

### 9.2 @Sendable 적용

- 비동기 클로저에서 안전한 값 캡처
- Sendable 프로토콜 준수를 통한 타입 안전성 확보
- 동시성 관련 버그 방지

## 10. 설계 최적화

### 10.1 메모리 관리

- 메모리 누수 방지를 위한 약한 참조 사용
- 적절한 라이프사이클 관리
- 리소스 해제 보장

### 10.2 성능 최적화

- 불필요한 UI 업데이트 최소화
- 효율적인 데이터 로딩 및 캐싱
- 백그라운드 작업 최적화

### 10.3 배터리 사용량 최적화

- 백그라운드 처리 최소화
- 센서 및 타이머 사용 최적화
- LiveActivity 효율적 사용

## 11. 향후 개선 방향

### 11.1 기능 확장

- 사용자 간 템플릿 공유 기능
- 고급 통계 분석 및 시각화
- 게임화 요소 도입

### 11.2 인프라 개선

- 클라우드 동기화 기능 강화
- 백엔드 서비스 통합
- 성능 모니터링 도구 도입

### 11.3 플랫폼 확장

- iPad 최적화
- watchOS 지원 확대
- 웨어러블 기기 연동 강화

## 12. 결론

Spotter 앱은 현대적인 iOS 개발 기술과 패턴을 활용하여 사용자에게 편리하고 효과적인 운동 트래킹 경험을 제공합니다. 클린 아키텍처와 모듈식 설계를 통해 지속적인 개선과, 기능 확장이 용이한 구조를 갖추고 있으며, 특히 LiveActivity와 같은 최신 iOS 기능을 활용하여 차별화된 사용자 경험을 제공합니다.

앞으로도 사용자 피드백을 반영하고 iOS 플랫폼의 발전에 맞춰 지속적으로 개선해 나갈 계획입니다.

## 13. 폴더 구조

프로젝트의 코드 구성은 기능과 아키텍처 계층에 따라 논리적으로 구성되어 있습니다.

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
│   │   ├── WorkoutSession.swift
│   │   ├── WorkoutTemplate.swift
│   │   ├── WorkoutSet.swift
│   │   ├── ExerciseItem.swift
│   │   └── MuscleGroup.swift
│   ├── UseCases/           # 비즈니스 로직
│   └── Repositories/       # 데이터 액세스 추상화
│
├── Data/                   # 데이터 계층
│   ├── Repositories/       # 리포지토리 구현
│   └── DataSources/        # 데이터 소스
│
├── Services/               # 앱 서비스
│   ├── WorkoutService.swift
│   ├── TimerService.swift
│   └── NotificationService.swift
│
├── Presentation/           # 프레젠테이션 계층
│   ├── Common/             # 공통 UI 요소
│   └── Features/           # 기능별 UI 요소
│
├── Views/                  # 화면 및 뷰
│   ├── ActiveWorkout/      # 활성 운동 화면
│   ├── HistoryTab/         # 운동 기록 화면
│   ├── WorkoutSelection/   # 운동 선택 화면
│   ├── StartTab/           # 시작 탭 화면
│   ├── SettingTab/         # 설정 탭 화면
│   ├── Onboarding/         # 온보딩 화면
│   ├── Auth/               # 인증 화면
│   └── Components/         # 재사용 가능한 컴포넌트
│
├── ViewModels/             # 뷰 모델
│   ├── WorkoutViewModel.swift
│   ├── HistoryViewModel.swift
│   └── SettingsViewModel.swift
│
├── Utils/                  # 유틸리티 함수
│   ├── DateUtils.swift
│   ├── FormatUtils.swift
│   └── ValidationUtils.swift
│
├── Extensions/             # 확장 함수
│   ├── UIKit+Extensions.swift
│   ├── SwiftUI+Extensions.swift
│   └── Foundation+Extensions.swift
│
├── Resources/              # 리소스 파일
│   ├── Fonts/              # 폰트
│   ├── Localization/       # 현지화 파일
│   └── JSON/               # JSON 데이터
│
└── Assets.xcassets/        # 이미지 및 색상 에셋
```

## 14. 이름 규칙 및 코드 가이드라인

### 14.1 파일 및 디렉토리 이름

- **파일 이름**: PascalCase 사용 (예: `WorkoutViewModel.swift`)
- **디렉토리 이름**: PascalCase 사용 (예: `ActiveWorkout/`)
- **확장 프로토콜 파일**: `[Type]+[Feature].swift` 형식 (예: `View+Theme.swift`)

### 14.2 코드 명명 규칙

- **클래스/구조체/열거형**: PascalCase 사용 (예: `WorkoutSession`)
- **변수/상수/함수**: camelCase 사용 (예: `startTime`, `calculateTotalWeight()`)
- **프로토콜**: PascalCase, 주로 명사/형용사 사용 (예: `Identifiable`, `WorkoutManageable`)
- **타입 별칭**: PascalCase 사용 (예: `typealias WorkoutID = UUID`)
- **열거형 케이스**: camelCase 사용 (예: `enum ActivityMode { case workoutMode, restTimerMode }`)

### 14.3 SwiftUI 뷰 구성 가이드라인

- 뷰 구조체는 `View` 프로토콜을 준수
- 복잡한 뷰는 더 작은 컴포넌트로 분리
- 뷰 확장을 통해 `body` 외 다른 뷰 컴포넌트 정의
- 뷰 수정자는 가독성을 위해 새 줄에 배치

```swift
struct WorkoutDetailView: View {
    // 속성 정의
    
    var body: some View {
        VStack {
            headerView
            contentView
            footerView
        }
        .padding()
        .background(Color.background)
    }
}

// 확장을 통한 서브뷰 구성
extension WorkoutDetailView {
    private var headerView: some View {
        // 헤더 뷰 구현
    }
    
    private var contentView: some View {
        // 컨텐츠 뷰 구현
    }
    
    private var footerView: some View {
        // 푸터 뷰 구현
    }
}
```

### 14.4 MVVM 패턴 가이드라인

- **모델 (Model)**: 순수 데이터 구조 및 비즈니스 로직
- **뷰 (View)**: UI 표현만 담당
- **뷰모델 (ViewModel)**: 상태 관리 및 데이터 변환
  - `@Published` 속성을 통한 상태 관리
  - 비즈니스 로직 처리를 위한 서비스 주입

```swift
final class WorkoutViewModel: ObservableObject {
    // 상태 정의
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 서비스 주입
    private let workoutService: WorkoutServiceProtocol
    
    init(workoutService: WorkoutServiceProtocol) {
        self.workoutService = workoutService
    }
    
    // 비즈니스 로직 메서드
    func loadWorkoutSessions() async {
        // 구현 내용
    }
}
```

### 14.5 SwiftData 사용 가이드라인

- 모델 클래스에 `@Model` 매크로 사용
- 관계는 `@Relationship` 속성 사용
- 영구 식별자에 `id` 속성 활용
- 모델 컨테이너는 `SwiftDataManager`를 통해 중앙 관리

### 14.6 비동기 작업 가이드라인

- `async`/`await` 기반 비동기 함수 활용
- 장시간 실행 작업에 `Task` 사용
- UI 업데이트는 메인 스레드에서 수행
- 비동기 클로저는 `@Sendable` 준수 확인

## 15. 구현된 기능 목록

Spotter 앱에 구현된 주요 기능을 상세히 설명합니다.

### 15.1 사용자 인증 및 프로필

- **계정 관리**
  - 이메일/소셜 로그인
  - 사용자 프로필 관리
  - 비밀번호 재설정

- **온보딩 경험**
  - 앱 초기 사용 안내
  - 운동 목표 설정
  - 사용자 경험 맞춤화

### 15.2 운동 템플릿 관리

- **템플릿 구성**
  - 새 운동 템플릿 생성
  - 템플릿 편집 및 복제
  - 템플릿 삭제 및 정렬

- **운동 항목 라이브러리**
  - 기본 제공 운동 항목
  - 사용자 정의 운동 생성
  - 근육 그룹별 분류 및 필터링

- **템플릿 공유**
  - 템플릿 내보내기
  - QR 코드를 통한 공유
  - 공유 템플릿 가져오기

### 15.3 운동 세션 관리

- **세션 추적**
  - 세션 시작 및 종료
  - 실시간 진행 상황 표시
  - 자동 휴식 타이머

- **세트 관리**
  - 무게 및 반복 횟수 기록
  - 세트 완료 상태 추적
  - 이전 기록 자동 불러오기
  - 슈퍼세트 지원

- **운동 통계**
  - 세션 요약 정보
  - 총 무게 및 볼륨 계산
  - 운동 시간 및 휴식 시간 분석

### 15.4 실시간 활동 (LiveActivity) 기능

- **운동 모드 LiveActivity**
  - 현재 운동 정보 표시
  - 진행 중인 세트 정보
  - 전체 진행률 표시

- **휴식 타이머 LiveActivity**
  - 실시간 카운트다운 타이머
  - 다음 운동 정보 표시
  - 타이머 완료 알림

- **모드 전환 효과**
  - 운동 모드 ↔ 휴식 모드 부드러운 전환
  - 진행 상태에 따른 UI 업데이트
  - 백그라운드에서도 정확한 타이밍 유지

### 15.5 운동 기록 및 분석

- **히스토리 관리**
  - 완료된 운동 세션 목록
  - 날짜별/템플릿별 필터링
  - 세션 상세 정보 확인

- **데이터 시각화**
  - 운동 통계 그래프
  - 기간별 추세 분석
  - 무게/볼륨 진행 추적

- **데이터 내보내기**
  - CSV/JSON 형식 내보내기
  - 건강 앱 연동
  - 백업 및 복원

### 15.6 테마 및 사용자 설정

- **시각적 테마**
  - 다크/라이트 모드 지원
  - 자동 테마 변경
  - 사용자 정의 색상 설정

- **앱 설정**
  - 알림 설정
  - 기본 휴식 시간 설정
  - 무게 단위 설정 (kg/lb)

- **접근성**
  - 다이나믹 텍스트 크기 지원
  - 고대비 모드
  - 음성 안내 지원

### 15.7 타이머 및 알림

- **내장 타이머**
  - 세트 간 휴식 타이머
  - 서킷 타이머
  - HIIT 타이머

- **알림 시스템**
  - 휴식 종료 알림
  - 예정된 운동 리마인더
  - 운동 목표 달성 축하 알림

- **백그라운드 처리**
  - 앱 백그라운드 시 타이머 지속
  - LiveActivity 업데이트
  - 저전력 작동 모드

## 16. 데이터 흐름 및 상태 관리

### 16.1 데이터 흐름

```
[사용자 인터랙션] → [뷰] → [뷰모델] → [유스케이스] → [리포지토리] → [데이터 소스]
      ↑                                                                  ↓
      └────────────────── [상태 업데이트] ◄───────────────────────────────┘
```

### 16.2 상태 관리 전략

- **단방향 데이터 흐름**: 예측 가능한 앱 상태 변화
- **환경 값(EnvironmentObject)**: 앱 전체에서 접근해야 하는 상태
- **지역화된 상태(@State, @StateObject)**: 단일 뷰 내에서만 사용되는 상태
- **상태 전파(@Binding, @Published)**: 부모-자식 뷰 간 상태 공유

### 16.3 이벤트 처리

- **NotificationCenter**: 컴포넌트 간 느슨한 결합 통신
- **Combine 프레임워크**: 반응형 이벤트 스트림 처리
- **클로저 콜백**: 간단한 이벤트 처리에 활용
