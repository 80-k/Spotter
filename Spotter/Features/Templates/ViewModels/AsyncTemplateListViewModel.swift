// AsyncTemplateListViewModel.swift
// Swift Concurrency를 활용한 비동기 템플릿 관리 ViewModel
// Created by woo on 4/1/25.

import Foundation
import SwiftData
import Combine

@MainActor
final class AsyncTemplateListViewModel: ObservableObject {
    // MARK: - 프로퍼티
    private let repository: TemplateRepository
    private let sessionRepository: SessionRepository?
    private var fetchTask: Task<Void, Never>?
    
    @Published var templates: [WorkoutTemplate] = []
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    
    // 이전 errorMessage 프로퍼티와의 호환성 유지
    var errorMessage: String? {
        error?.userMessage
    }
    
    // MARK: - 초기화
    init(repository: TemplateRepository, sessionRepository: SessionRepository? = nil) {
        self.repository = repository
        self.sessionRepository = sessionRepository
        
        // 초기화 후 템플릿 로딩
        fetchTask = Task { await fetchTemplates() }
    }
    
    deinit {
        // 진행 중인 작업 취소
        fetchTask?.cancel()
    }
    
    // MARK: - 템플릿 로딩
    func fetchTemplates() async {
        // 기존 작업 취소
        fetchTask?.cancel()
        
        // 새 작업 시작
        fetchTask = Task {
            // 로딩 상태 업데이트
            isLoading = true
            error = nil
            
            // Result 타입 활용
            let result = await repository.getAllAsyncResult(sortBy: [SortDescriptor(\WorkoutTemplate.lastUsed, order: .reverse)])
            
            switch result {
            case .success(let fetchedTemplates):
                // 성공 시 UI 업데이트
                templates = fetchedTemplates
            case .failure(let appError):
                // 오류 발생 시 처리
                error = appError
                print("템플릿 로딩 오류: \(appError.debugDescription)")
            }
            
            // 로딩 상태 종료
            isLoading = false
        }
    }
    
    // MARK: - 템플릿 CRUD 작업
    
    // 새 템플릿 추가
    func addTemplate(name: String) async {
        guard !name.isEmpty else {
            error = .invalidInput("템플릿 이름이 비어있습니다")
            return
        }
        
        // 비어있는 템플릿 생성
        let newTemplate = WorkoutTemplate(name: name)
        
        // 저장소에 저장
        let result = await repository.saveAsyncResult(newTemplate)
        
        switch result {
        case .success:
            // 성공 시 템플릿 목록 새로고침
            await fetchTemplates()
        case .failure(let appError):
            error = appError
            print("템플릿 생성 오류: \(appError.debugDescription)")
        }
    }
    
    // 템플릿 업데이트
    func updateTemplate(_ template: WorkoutTemplate) async {
        let result = await repository.saveAsyncResult(template)
        
        switch result {
        case .success:
            // 성공 시 목록에서 해당 템플릿 업데이트
            if let index = templates.firstIndex(where: { $0.id == template.id }) {
                templates[index] = template
            }
        case .failure(let appError):
            error = appError
            print("템플릿 업데이트 오류: \(appError.debugDescription)")
        }
    }
    
    // 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) async {
        let result = await repository.deleteAsyncResult(template)
        
        switch result {
        case .success:
            // 성공 시 목록에서 해당 템플릿 제거
            templates.removeAll { $0.id == template.id }
        case .failure(let appError):
            error = appError
            print("템플릿 삭제 오류: \(appError.debugDescription)")
        }
    }
    
    // 여러 템플릿 삭제
    func deleteTemplates(_ templatesToDelete: [WorkoutTemplate]) async {
        // 모든 삭제 작업을 병렬로 처리하기 위한 TaskGroup 사용
        await withTaskGroup(of: Result<Void, AppError>.self) { group in
            for template in templatesToDelete {
                group.addTask {
                    await self.repository.deleteAsyncResult(template)
                }
            }
            
            // 결과 수집
            var errors: [AppError] = []
            
            for await result in group {
                if case .failure(let error) = result {
                    errors.append(error)
                }
            }
            
            // 오류 발생 여부에 따라 처리
            if let firstError = errors.first {
                error = firstError
                print("여러 템플릿 삭제 중 오류 발생: \(errors.count)개 작업 실패")
            } else {
                // 성공 시 목록에서 삭제된 템플릿들 제거
                templates.removeAll { template in
                    templatesToDelete.contains { $0.id == template.id }
                }
            }
        }
    }
    
    // MARK: - 운동 세션 관리
    
    // 템플릿으로 운동 시작
    func startWorkout(with template: WorkoutTemplate) async -> WorkoutSession? {
        guard let sessionRepository = sessionRepository else {
            error = .customError("세션 저장소를 사용할 수 없습니다")
            return nil
        }
        
        // 템플릿 사용 날짜 업데이트
        template.lastUsed = Date()
        let saveResult = await repository.saveAsyncResult(template)
        
        guard case .success = saveResult else {
            if case .failure(let appError) = saveResult {
                error = appError
            }
            return nil
        }
        
        do {
            // 새 세션 생성 (throws 방식 사용)
            return try await sessionRepository.createSessionAsync(with: template)
        } catch {
            self.error = .persistenceError("운동 세션 생성 실패: \(error.localizedDescription)")
            print("운동 세션 생성 오류: \(error)")
            return nil
        }
    }
    
    // MARK: - 템플릿 필터링
    
    // 운동 갯수로 필터링
    func templatesWithExerciseCount(min: Int, max: Int? = nil) -> [WorkoutTemplate] {
        templates.filter { template in
            let count = template.exercises.count
            if let max = max {
                return count >= min && count <= max
            } else {
                return count >= min
            }
        }
    }
    
    // 최근 사용된 템플릿 필터링
    var recentlyUsedTemplates: [WorkoutTemplate] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        return templates.filter { template in
            guard let lastUsed = template.lastUsed else { return false }
            return lastUsed > thirtyDaysAgo
        }.sorted { ($0.lastUsed ?? Date.distantPast) > ($1.lastUsed ?? Date.distantPast) }
    }
    
    // 오류 지우기
    func clearError() {
        error = nil
    }
} 