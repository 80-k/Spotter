// ActorTemplateViewModel+TemplateManagement.swift
// 템플릿 CRUD 관련 기능을 분리한 확장
// Created by woo on 4/16/25.

import Foundation
import SwiftData

// 템플릿 관리 기능을 위한 확장
extension ActorTemplateViewModel {
    // MARK: - 템플릿 관리
    
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
    func deleteTemplate(_ template: WorkoutTemplate) async throws {
        let task = addOperation {
            try await self.dataActor.deleteTemplate(template)
            
            // UI 갱신은 dataActor에서 가져오는 것보다 더 빠르게 처리
            await MainActor.run {
                self.templates.removeAll { $0.id == template.id }
            }
        }
        
        // 작업 완료 대기
        try await task.value
    }
    
    /// 여러 템플릿 삭제
    func deleteTemplates(_ templatesToDelete: [WorkoutTemplate]) async throws {
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
        
        // 작업 완료 대기
        try await task.value
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
    func searchTemplates(matching query: String) async throws -> [WorkoutTemplate] {
        return try await dataActor.findTemplates(matching: query)
    }
    
    /// 특정 운동을 포함하는 템플릿 검색
    func findTemplatesWithExercise(exerciseId: PersistentIdentifier) async throws -> [WorkoutTemplate] {
        return try await dataActor.findTemplates(containingExercise: exerciseId)
    }
    
    /// 템플릿 검색 (TemplateDataSource 구현)
    func searchTemplates(matching query: String) async {
        guard !query.isEmpty else {
            // 검색어가 비어있으면 전체 목록 로드
            loadTemplates()
            return
        }
        
        let task = addOperation {
            return try await self.dataActor.findTemplates(matching: query)
        }
        
        do {
            let results = try await task.value
            self.templates = results
        } catch {
            handleError(error)
        }
    }
} 