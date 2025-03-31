// ActorTemplateViewModel.swift
// Actor를 활용한 ViewModel 구현으로 스레드 안전성 보장
// Created by woo on 4/1/25.

import Foundation
import SwiftData
import Combine

/// 작업 진행 상태를 표시할 수 있는 프로토콜
protocol OperationStateReporting {
    /// 진행 중인 작업 개수
    var pendingOperationsCount: Int { get }
    
    /// 작업 상태 업데이트 
    func updateOperationState(delta: Int)
}

@MainActor
final class ActorTemplateViewModel: ObservableObject, TemplateDataSource, OperationStateReporting {
    // MARK: - 프로퍼티
    
    // 데이터 접근용 Actor
    private let dataActor: TemplateDataActor
    private let sessionRepository: SessionRepository?
    
    // 비동기 작업 관리
    private var fetchTask: Task<Void, Never>?
    private var operations = [UUID: Task<Void, Never>]()
    
    // UI 상태
    @Published var templates: [WorkoutTemplate] = []
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    
    // 작업 상태 추적
    @Published var pendingOperationsCount: Int = 0
    
    // 운영 상태
    private var isFirstLoad = true
    
    // MARK: - 초기화
    
    init(repository: TemplateRepository, sessionRepository: SessionRepository? = nil) {
        self.dataActor = TemplateDataActor(repository: repository)
        self.sessionRepository = sessionRepository
        
        // 초기 데이터 로드
        loadTemplates()
    }
    
    deinit {
        cancelAllTasks()
    }
    
    // MARK: - TemplateDataSource 구현
    
    /// 다른 데이터 소스로부터 이 뷰모델의 상태 업데이트
    func updateState(from source: TemplateDataSource) {
        Task { @MainActor in
            self.templates = source.templates
            self.error = source.error
            self.isLoading = source.isLoading
            
            // OperationStateReporting 구현체인 경우 작업 상태도 업데이트
            if let operationSource = source as? OperationStateReporting {
                self.pendingOperationsCount = operationSource.pendingOperationsCount
            }
        }
    }
    
    // MARK: - 태스크 관리
    
    /// 모든 비동기 작업 취소
    private func cancelAllTasks() {
        fetchTask?.cancel()
        operations.values.forEach { $0.cancel() }
        operations.removeAll()
    }
    
    /// 지정된 ID의 작업 취소
    private func cancelOperation(id: UUID) {
        operations[id]?.cancel()
        operations[id] = nil
        updatePendingOperationsCount()
    }
    
    /// 새 작업 추가
    private func addOperation<T>(_ operation: () async throws -> T) -> Task<T, Error> {
        let taskID = UUID()
        let task = Task<T, Error> {
            do {
                updatePendingOperationsCount()
                let result = try await operation()
                cancelOperation(id: taskID)
                return result
            } catch {
                cancelOperation(id: taskID)
                throw error
            }
        }
        
        operations[taskID] = Task {
            do {
                _ = try await task.value
            } catch {
                handleError(error)
            }
        }
        
        updatePendingOperationsCount()
        return task
    }
    
    /// 작업 개수 업데이트
    private func updatePendingOperationsCount() {
        pendingOperationsCount = operations.count
    }
    
    // MARK: - 데이터 로딩
    
    /// 템플릿 목록 로드
    func loadTemplates() {
        if fetchTask != nil && !isFirstLoad {
            // 이미 로딩 중이면 중복 요청 방지
            return
        }
        
        isFirstLoad = false
        isLoading = true
        
        fetchTask = Task {
            defer {
                isLoading = false
                fetchTask = nil
            }
            
            do {
                templates = try await dataActor.getTemplates()
                error = nil
            } catch {
                handleError(error)
            }
        }
    }
    
    /// 템플릿 추가
    func addTemplate(name: String) async throws -> WorkoutTemplate {
        guard !name.isEmpty else {
            throw AppError.invalidInput("템플릿 이름이 비어있습니다.")
        }
        
        let newTemplate = WorkoutTemplate(name: name)
        
        // 작업 추가 및 실행
        let task = addOperation {
            try await self.dataActor.saveTemplate(newTemplate)
            return newTemplate
        }
        
        do {
            let savedTemplate = try await task.value
            // 템플릿 목록 갱신
            self.templates = try await self.dataActor.getTemplates()
            return savedTemplate
        } catch {
            handleError(error)
            throw error
        }
    }
    
    /// 템플릿 업데이트
    func updateTemplate(_ template: WorkoutTemplate) {
        let task = addOperation {
            try await self.dataActor.saveTemplate(template)
            
            // 메모리에 있는 템플릿 목록 갱신
            if let index = self.templates.firstIndex(where: { $0.id == template.id }) {
                self.templates[index] = template
            }
        }
        
        // 태스크가 자동으로 실행되고 완료됨
    }
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) {
        let task = addOperation {
            try await self.dataActor.deleteTemplate(template)
            
            // UI 갱신은 dataActor에서 가져오는 것보다 더 빠르게 처리
            await MainActor.run {
                self.templates.removeAll { $0.id == template.id }
            }
        }
        
        // 태스크가 자동으로 실행되고 완료됨
    }
    
    /// 여러 템플릿 삭제
    func deleteTemplates(_ templatesToDelete: [WorkoutTemplate]) {
        let task = addOperation {
            // Task 그룹으로 병렬 처리
            try await withThrowingTaskGroup(of: Void.self) { group in
                for template in templatesToDelete {
                    group.addTask {
                        try await self.dataActor.deleteTemplate(template)
                    }
                }
                
                // 전체 완료 대기
                try await group.waitForAll()
            }
            
            // UI 갱신
            await MainActor.run {
                self.templates.removeAll { template in
                    templatesToDelete.contains { $0.id == template.id }
                }
            }
        }
        
        // 태스크가 자동으로 실행되고 완료됨
    }
    
    /// 운동 세션 시작
    func startWorkout(with template: WorkoutTemplate) async throws -> WorkoutSession? {
        guard let sessionRepository = sessionRepository else {
            throw AppError.customError("세션 저장소를 사용할 수 없습니다")
        }
        
        // 마지막 사용 시간 업데이트
        template.lastUsed = Date()
        
        let task = addOperation {
            // 템플릿 업데이트
            try await self.dataActor.saveTemplate(template)
            
            // 세션 생성
            return try await sessionRepository.createSessionAsync(with: template)
        }
        
        return try await task.value
    }
    
    // MARK: - 검색 및 필터링
    
    /// 이름으로 템플릿 검색
    func searchTemplates(query: String) async throws -> [WorkoutTemplate] {
        return try await dataActor.findTemplates(matching: query)
    }
    
    /// 특정 운동을 포함하는 템플릿 검색
    func findTemplatesWithExercise(exerciseId: PersistentIdentifier) async throws -> [WorkoutTemplate] {
        return try await dataActor.findTemplates(containingExercise: exerciseId)
    }
    
    /// 최근 사용된 템플릿 가져오기
    var recentlyUsedTemplates: [WorkoutTemplate] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        return templates.filter { template in
            guard let lastUsed = template.lastUsed else { return false }
            return lastUsed > thirtyDaysAgo
        }.sorted { ($0.lastUsed ?? Date.distantPast) > ($1.lastUsed ?? Date.distantPast) }
    }
    
    // MARK: - 오류 처리
    
    /// 오류 처리
    private func handleError(_ error: Error) {
        if let appError = error as? AppError {
            self.error = appError
        } else {
            self.error = .customError(error.localizedDescription)
        }
        
        print("오류 발생: \(error.localizedDescription)")
    }
    
    /// 오류 지우기
    func clearError() {
        error = nil
    }
    
    /// 캐시 강제 갱신
    func refreshCache() {
        let task = addOperation {
            try await self.dataActor.refreshCache()
            self.templates = try await self.dataActor.getTemplates()
        }
        
        // 태스크가 자동으로 실행되고 완료됨
    }
    
    /// OperationStateReporting 구현
    func updateOperationState(delta: Int) {
        pendingOperationsCount += delta
    }
} 