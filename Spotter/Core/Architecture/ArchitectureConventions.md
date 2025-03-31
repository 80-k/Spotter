# 아키텍처 컨벤션 가이드라인

이 문서는 Spotter 앱의 아키텍처 패턴과 컨벤션에 대한 가이드라인을 제공합니다. 일관된 코드 구조와 디자인 패턴을 유지하기 위한 지침을 따르세요.

## 아키텍처 개요

Spotter는 다음 아키텍처 패턴을 조합하여 사용합니다:

1. **MVVM (Model-View-ViewModel)**: UI 로직과 비즈니스 로직을 분리
2. **Repository 패턴**: 데이터 접근 계층 추상화
3. **의존성 주입 (DI)**: 컴포넌트 간 결합도 감소
4. **Actor 기반 동시성**: 스레드 안전한 상태 관리

## 각 컴포넌트 역할

### Model
- 앱의 데이터 구조와 비즈니스 로직을 정의
- SwiftData 모델 클래스로 구현 (`@Model` 사용)
- 데이터 검증 및 기본적인 비즈니스 규칙 포함

```swift
@Model
final class WorkoutTemplate {
    var name: String
    var exercises: [ExerciseItem] = []
    var lastUsed: Date?
    
    init(name: String) {
        self.name = name
    }
    
    func addExercise(_ exercise: ExerciseItem, sets: Int) {
        // 비즈니스 로직 구현
    }
}
```

### Repository
- 데이터 소스에 대한 추상화 계층
- CRUD 작업을 위한 일관된 인터페이스 제공
- 프로토콜로 정의하고 구체적인 구현체 제공
- 동기 및 비동기 메서드 모두 제공 (`async/await` 활용)

```swift
protocol TemplateRepository {
    // 동기 메서드
    func getAll() -> [WorkoutTemplate]
    
    // 비동기 메서드
    func getAllAsync() async -> [WorkoutTemplate]
}
```

### ViewModel
- 뷰에 필요한 데이터와 상태 관리
- 사용자 입력 처리 및 비즈니스 로직 호출
- 뷰에 바인딩할 수 있는 `@Published` 프로퍼티 제공
- 뷰의 라이프사이클 관리

#### 구현 패턴:

1. **일반 ViewModel**: 기본적인 MVVM 구현

```swift
class TemplateListViewModel: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []
    private let repository: TemplateRepository
}
```

2. **Actor 기반 ViewModel**: 스레드 안전한 상태 관리

```swift
@MainActor
class ActorTemplateViewModel: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []
    private let dataActor: TemplateDataActor
}
```

3. **AsyncViewModel**: Swift Concurrency 활용

```swift
class AsyncTemplateListViewModel: ObservableObject {
    @Published var templates: [WorkoutTemplate] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var fetchTask: Task<Void, Never>?
}
```

### View
- UI 표현 및 사용자 상호작용 처리
- SwiftUI 구조체로 구현
- ViewModel에 의존하여 데이터 표시 및 상태 관리
- 단일 책임 원칙 준수 (UI 표현만 담당)

```swift
struct TemplateListView: View {
    @StateObject private var viewModel: TemplateListViewModel
    
    var body: some View {
        // UI 구현
    }
}
```

## 의존성 주입

- 컴포넌트 간의 결합도를 낮추기 위해 의존성 주입 사용
- `DependencyContainer`를 통한 중앙화된 의존성 관리
- SwiftUI의 `@EnvironmentObject`를 활용한 의존성 주입

```swift
// 의존성 컨테이너
class DependencyContainer: ObservableObject {
    func makeTemplateRepository() -> TemplateRepository {
        // 구현체 생성 및 반환
    }
    
    func makeTemplateViewModel() -> TemplateListViewModel {
        // ViewModel 생성 및 반환
    }
}

// 뷰에서 의존성 주입
struct ContentView: View {
    @EnvironmentObject var diContainer: DependencyContainer
    
    var body: some View {
        // diContainer를 통해 의존성 주입
    }
}
```

## 비동기 작업 관리

1. **Swift Concurrency**
   - `async/await`와 `Task`를 활용한 비동기 작업 처리
   - 작업 취소 및 에러 처리 지원

2. **Actor 활용**
   - 데이터 일관성을 보장하는 스레드 안전한 상태 관리
   - 백그라운드 작업의 동시성 관리

```swift
actor TemplateDataActor {
    private let repository: TemplateRepository
    
    func getTemplates() async throws -> [WorkoutTemplate] {
        // 스레드 안전한 데이터 접근
    }
}
```

## 에러 처리

- 통일된 에러 타입 사용 (`AppError`)
- UI에 표시할 사용자 친화적인 메시지 포함
- 디버깅을 위한 상세 정보 보존

```swift
enum AppError: Error {
    case networkError(Error)
    case databaseError(Error)
    case validationError(String)
    
    var userMessage: String {
        // 사용자 친화적인 에러 메시지 반환
    }
}
```

## 파일 구조 컨벤션

- 각 컴포넌트는 개별 파일로 분리
- 이름 규칙: `[기능명][컴포넌트타입].swift`
  - 예: `TemplateListView.swift`, `TemplateListViewModel.swift`
- 복잡한 컴포넌트는 논리적인 단위로 분리 