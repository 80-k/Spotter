# 폴더 구조 가이드라인

이 문서는 Spotter 앱의 폴더 구조에 대한 가이드라인을 제공합니다. 앱의 코드를 체계적으로 구성하고 유지보수하기 위한 지침을 따르세요.

## 기본 폴더 구조

```
Spotter/
├── App/                    # 앱 진입점 및 생명주기 관련 코드
├── Core/                   # 핵심 공통 컴포넌트 및 기반 구조
│   ├── Architecture/       # 아키텍처 가이드라인 및 프로토콜
│   ├── Components/         # 재사용 가능한 UI 외 공통 컴포넌트
│   ├── Extensions/         # Swift 기본 타입 확장
│   ├── Models/             # 핵심 데이터 모델
│   ├── Repository/         # 데이터 접근 계층 (Repository 패턴)
│   ├── Services/           # 앱 전체에서 사용하는 서비스
│   ├── Utils/              # 유틸리티 함수 및 헬퍼
│   └── Views/              # 재사용 가능한 UI 컴포넌트
└── Features/               # 기능별 모듈
    ├── [기능명]/           # 특정 기능 관련 코드
    │   ├── Models/         # 기능별 모델
    │   ├── ViewModels/     # 기능별 뷰모델
    │   ├── Views/          # 기능별 화면 및 뷰
    │   │   └── Components/ # 기능 내에서만 사용되는 UI 컴포넌트
    │   └── Services/       # 기능별 서비스
    └── ...
```

## 핵심 원칙

### 1. 관심사 분리 (Separation of Concerns)
- 각 폴더와 파일은 명확한 책임과 목적을 가져야 합니다
- 코드의 범위와 책임을 명확히 구분하여 불필요한 의존성을 줄입니다

### 2. 의존성 방향 (Dependency Direction)
- 의존성은 항상 안쪽에서 바깥쪽으로 향해야 합니다 (Core ← Features)
- Features 간의 직접적인 의존성은 피하고, 필요시 Core를 통해 소통합니다

### 3. 컴포넌트 배치 규칙 (Component Placement Rules)
- 여러 기능에서 사용되는 공통 컴포넌트는 `Core/Views/`에 배치
- 특정 기능 내에서만 사용되는 컴포넌트는 `Features/[기능명]/Views/Components/`에 배치
- UI 외 재사용 가능한 컴포넌트는 `Core/Components/`에 배치

## 폴더별 역할 가이드

### Core/Views/
UI 관련 재사용 가능한 컴포넌트를 포함합니다. 이 폴더의 컴포넌트는:
- 특정 기능에 종속되지 않아야 합니다
- 명확한 API와 문서화를 갖춰야 합니다
- 독립적으로 테스트 가능해야 합니다
- 예시: `LoadingView`, `ErrorView`, `EmptyStateView`

### Core/Components/
UI 외의 재사용 가능한 공통 컴포넌트를 포함합니다:
- UI 스타일 모디파이어
- 공통 애니메이션
- 커스텀 레이아웃 매니저
- 예시: `StyleModifiers`, `AnimationManager`

### Features/[기능명]/Views/
특정 기능의 주요 화면을 포함합니다:
- 해당 기능의 핵심 화면 구성
- ViewModel과 통합된 전체 화면
- 예시: `TemplateListView`, `WorkoutDetailView`

### Features/[기능명]/Views/Components/
특정 기능 내에서만 사용되는 UI 컴포넌트:
- 해당 기능에 특화된 UI 요소
- 기능 외부에서는 재사용되지 않는 컴포넌트
- 예시: `TemplateListSectionView`, `WorkoutStatsCard`

## 이름 지정 규칙

- **파일명**: 명확하고 설명적인 이름 사용 (예: `WorkoutTemplateView.swift`)
- **폴더명**: 복수형 사용 (예: `Views`, `Models`, `Services`)
- **기능 폴더**: 기능 이름 사용 (예: `Templates`, `ActiveWorkout`)

## 마이그레이션 가이드

기존 `Spotter/Views/` 폴더의 콘텐츠를 다음과 같이 마이그레이션합니다:

1. 공통 뷰 컴포넌트: `Core/Views/`로 이동
2. 기능별 화면: 각 `Features/[기능명]/Views/`로 이동
3. 기능별 컴포넌트: 각 `Features/[기능명]/Views/Components/`로 이동 