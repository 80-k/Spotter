# Spotter 앱 뷰 아키텍처 가이드라인

이 가이드라인은 앱 내의 뷰 컴포넌트 구성 및 분리에 대한 규칙을 정의합니다.

## 폴더 구조 및 역할

### 1. Core/Views
- **역할**: 앱 전체에서 재사용 가능한 독립적인 공통 뷰 컴포넌트
- **특징**:
  - 특정 기능에 의존하지 않음
  - 재사용이 간단함
  - 데이터 모델에 직접 접근하지 않음
  - 일관된 디자인 시스템 제공
- **예시**: `EmptyStateView`, `LoadingView`, `ErrorView` 등

### 2. Features/[기능명]/Views
- **역할**: 특정 기능의 화면을 구성하는 메인 뷰
- **특징**:
  - 주로 전체 화면을 차지하는 뷰
  - 해당 기능의 ViewModel과 결합
  - 네비게이션 및 사용자 인터랙션 관리
  - 해당 기능에 대한 완전한 사용자 경험 제공
- **예시**: `ExerciseSelectionView`, `TemplateListView`, `ActiveWorkoutView` 등

### 3. Features/[기능명]/Views/Components
- **역할**: 특정 기능에 특화된 하위 컴포넌트
- **특징**:
  - 해당 기능에서만 사용되는 특화된 뷰
  - Core/Views의 컴포넌트를 확장하거나 특화하여 사용
  - 복잡한 뷰의 일부분으로 분리하여 가독성과 재사용성 향상
- **예시**: `SearchResultView`, `CategoryFilterView`, `TemplateRowView` 등

## 개발 가이드라인

### 1. 원칙
- **단일 책임**: 각 뷰는 하나의 명확한 책임만 가져야 함
- **분리 규칙**: 6줄 이상 반복되는 코드 블록은 별도 컴포넌트로 분리 고려
- **의존성 방향**: Core ← Features (Features가 Core에 의존, 역방향 의존 금지)

### 2. Core/Views 개발 시
- 비즈니스 로직 포함하지 않기
- 최대한 일반적으로 재사용 가능하도록 설계
- 설정 옵션을 통해 유연성 제공
- 항상 프리뷰 포함하기

### 3. Features/Views 개발 시
- ViewModel 사용하여 비즈니스 로직 분리
- 적절한 컴포넌트 분해로 가독성 향상
- 재사용 가능한 요소는 Components 폴더로 분리
- 해당 기능 관련 상태 및 이벤트 처리에 집중

### 4. Components 개발 시
- 상위 뷰와 명확한 인터페이스 정의 (콜백 함수 등)
- 최소한의 외부 의존성만 가지도록 설계
- 상태 관리는 상위 뷰에서 처리하도록 구성

## 명명 규칙

1. **Core/Views**: 일반적인 역할 표현 (`EmptyStateView`, `CardView` 등)
2. **Features/Views**: 기능명 포함 (`ExerciseSelectionView`, `TemplateDetailView` 등)
3. **Components**: 구체적 역할 표현 (`SearchResultView`, `CategoryFilterView` 등)

## 예시: 컴포넌트 분리

```swift
// BAD: 너무 큰 단일 뷰
struct ExerciseListView: View {
    var body: some View {
        VStack {
            // 검색창 (20줄)
            // ...
            
            // 카테고리 필터 (30줄)
            // ...
            
            // 결과 목록 (50줄)
            // ...
        }
    }
}

// GOOD: 적절히 분리된 컴포넌트
struct ExerciseListView: View {
    var body: some View {
        VStack {
            SearchBarView(text: $searchText, onSubmit: search)
            CategoryFilterView(categories: categories, selected: $selectedCategory)
            ExerciseResultsView(results: filteredResults)
        }
    }
}
```

## 역할에 따른 분류 결정 가이드

1. **여러 기능에서 사용될 수 있는가?** → Core/Views
2. **특정 기능에 특화되었으나 여러 화면에서 재사용되는가?** → Features/Components
3. **특정 화면의 일부분인가?** → 해당 뷰 내부에 정의 또는 Components 폴더

이 가이드라인을 따르면 코드의 구조가 명확해지고, 재사용성이 높아지며, 유지보수가 용이해집니다. 