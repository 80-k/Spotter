import Foundation
import Combine

/// 모든 뷰모델 데이터 소스의 기본 프로토콜
protocol ViewModelDataSource: ObservableObject {
    /// 이 뷰모델의 고유 식별자
    static var identifier: String { get }
    
    /// 뷰모델이 현재 로딩 중인지 여부
    var isLoading: Bool { get }
    
    /// 뷰모델에서 발생한 오류
    var error: AppError? { get set }
    
    /// 오류 상태 초기화
    func clearError()
}

/// 기본 구현
extension ViewModelDataSource {
    /// 기본 식별자는 클래스 이름 기반
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    /// 오류 상태 초기화
    func clearError() {
        self.error = nil
    }
}

/// 템플릿 관련 데이터를 제공하는 프로토콜
protocol TemplateDataSource: ViewModelDataSource {
    /// 이 데이터소스가 제공하는 템플릿 목록
    var templates: [WorkoutTemplate] { get set }
    
    /// 템플릿 데이터 새로고침
    func refreshCache() async
    
    /// 새 템플릿 추가
    @discardableResult
    func addTemplate(name: String) async throws -> WorkoutTemplate
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) async throws
    
    /// 템플릿으로 운동 세션 시작
    @discardableResult
    func startWorkout(with template: WorkoutTemplate) async throws -> WorkoutSession?
    
    /// 이름으로 템플릿 검색
    func searchTemplates(matching query: String) async
}

/// 진행 중인 작업 상태 보고 프로토콜
protocol OperationStateReporting {
    /// 현재 진행 중인 백그라운드 작업 수
    var pendingOperationsCount: Int { get }
    
    /// 작업 상태 업데이트
    func updateOperationState(delta: Int)
}

/// 세션 관련 데이터를 제공하는 프로토콜
protocol SessionDataSource: ViewModelDataSource {
    /// 사용자의 운동 세션 목록
    var sessions: [WorkoutSession] { get }
    
    /// 세션 목록 새로고침
    func refreshSessions() async
    
    /// 특정 세션 로드
    func loadSession(_ sessionId: UUID) async throws -> WorkoutSession?
    
    /// 세션 저장
    func saveSession(_ session: WorkoutSession) async throws
}

/// 실시간 상태 업데이트 기능 제공 프로토콜
protocol RealtimeStateUpdating {
    /// 다른 뷰모델에서 데이터 상태 동기화
    func updateState<T: ViewModelDataSource>(from source: T)
}

// MARK: - UI 관련 속성

/// 방향 정보 열거형
enum SortDirection {
    case ascending
    case descending
}

/// 템플릿 정렬 옵션
enum TemplateSortOption: String, CaseIterable {
    case name = "이름"
    case lastUsed = "최근 사용"
    case useCount = "사용 빈도"
    case created = "생성일"
}

/// 세션 정렬 옵션
enum SessionSortOption: String, CaseIterable {
    case date = "날짜"
    case duration = "소요 시간"
    case exercises = "운동 수"
} 