# Spotter - 운동 기록 앱

최신 SwiftUI와 SwiftData를 활용한 운동 기록 앱입니다.

## 프로젝트 폴더 구조

```
Spotter/
├── Core/
│   ├── Components/            # 재사용 가능한 UI 컴포넌트
│   │   ├── EmptyStateView     # 빈 상태 화면 컴포넌트
│   │   └── StyleModifiers     # 스타일 모디파이어
│   ├── DI/                    # 의존성 주입 관련 클래스
│   │   ├── DependencyContainer       # 의존성 주입 컨테이너
│   │   └── DependencyContainerKey    # 환경 변수 키
│   └── Repository/            # 데이터 접근 계층 (Repository 패턴)
│       ├── ModelRepository    # 일반 리포지토리 인터페이스
│       ├── ExerciseRepository # 운동 관련 리포지토리
│       ├── TemplateRepository # 템플릿 관련 리포지토리
│       └── SessionRepository  # 세션 관련 리포지토리
├── Features/                  # 기능별 모듈화된 폴더
│   ├── ExerciseSelection/     # 운동 선택 기능
│   │   ├── ViewModels/        # 뷰모델 클래스
│   │   └── Views/             # 뷰 파일
│   │       └── Components/    # 해당 기능 전용 컴포넌트
│   └── Templates/             # 운동 템플릿 관련 기능
│       ├── ViewModels/        # 뷰모델 클래스 
│       └── Views/             # 뷰 파일
│           └── Components/    # 해당 기능 전용 컴포넌트
├── Models/                    # 모든 데이터 모델
├── Extensions/                # 확장 함수들
├── Utilities/                 # 유틸리티 함수 및 헬퍼 클래스
├── Services/                  # 외부 서비스 통합 (Firebase 등)
└── Views/                     # 공통 뷰 컴포넌트
```

## 아키텍처 가이드라인

### 1. 아키텍처 패턴

- **MVVM + Repository 패턴** 사용
  - Model: 데이터 모델 (SwiftData 모델 클래스)
  - ViewModel: 비즈니스 로직 및 상태 관리
  - View: UI 컴포넌트 (SwiftUI)
  - Repository: 데이터 접근 계층 추상화

### 2. 의존성 주입

- `DependencyContainer`를 통한 의존성 주입
- `EnvironmentValues` 확장으로 환경 변수 통합
- 뷰모델이 Repository에 의존하도록 구현
- SwiftData의 `ModelContext`는 Repository를 통해서만 접근

### 3. SwiftUI 모범 사례

- 일관된 뷰 모디파이어로 스타일 통일
- 재사용 가능한 작은 컴포넌트 설계
- iOS 16+ 네비게이션 API 활용
- 빈 상태 화면 등의 공통 패턴 컴포넌트화

### 4. 네이밍 규칙

- 파일명은 기능과 역할을 명확히 표현 (예: `TemplateListView.swift`)
- 클래스명은 역할을 명확히 표현 (예: `TemplateListViewModel`)
- 일관된 접두사/접미사 사용 (View, ViewModel, Repository 등)

## 최근 리팩토링 내용

1. Repository 패턴 구현으로 SwiftData 접근 추상화
2. 의존성 주입 컨테이너 도입
3. 환경 변수를 통한 깔끔한 의존성 접근
4. 공통 스타일 모디파이어 도입으로 디자인 일관성 확보
5. 복잡한 뷰 분해 및 컴포넌트화
6. 네비게이션 구조 간소화 및 최신 API 활용 