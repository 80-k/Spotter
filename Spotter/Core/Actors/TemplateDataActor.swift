// TemplateDataActor.swift
// Actor를 활용한 스레드 안전한 템플릿 데이터 접근
// Created by woo on 4/1/25.

import Foundation
import SwiftData

/// 템플릿 데이터에 대한 스레드 안전한 접근을 제공하는 Actor
actor TemplateDataActor {
    // MARK: - 프로퍼티
    
    // Actor 내부에서 사용할 저장소
    private let repository: TemplateRepository
    
    // 데이터 캐싱
    private var cachedTemplates: [WorkoutTemplate] = []
    private var lastFetchTime: Date?
    
    // 캐시 유효 시간 (5초)
    private let cacheValidityDuration: TimeInterval = 5
    
    // MARK: - 초기화
    
    init(repository: TemplateRepository) {
        self.repository = repository
    }
    
    // MARK: - 데이터 접근 메서드
    
    /// 모든 템플릿 가져오기 (캐시 활용)
    func getTemplates() async throws -> [WorkoutTemplate] {
        // 캐시가 유효한지 확인
        if let lastFetch = lastFetchTime, 
           Date().timeIntervalSince(lastFetch) < cacheValidityDuration,
           !cachedTemplates.isEmpty {
            // 유효한 캐시 데이터 반환
            return cachedTemplates
        }
        
        // 캐시 무효 - 새로 로드
        let templates = try await repository.getAllAsync(
            sortBy: [SortDescriptor(\WorkoutTemplate.lastUsed, order: .reverse)]
        )
        
        // 캐시 업데이트
        cachedTemplates = templates
        lastFetchTime = Date()
        
        return templates
    }
    
    /// 템플릿 저장
    func saveTemplate(_ template: WorkoutTemplate) async throws {
        try await repository.saveAsync(template)
        
        // 캐시 갱신
        invalidateCache()
    }
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) async throws {
        try await repository.deleteAsync(template)
        
        // 캐시 갱신
        invalidateCache()
    }
    
    /// 템플릿 검색
    func findTemplates(matching query: String) async throws -> [WorkoutTemplate] {
        if query.isEmpty {
            return try await getTemplates()
        }
        
        // 전체 템플릿 중에서 필터링 (캐시 활용)
        let allTemplates = try await getTemplates()
        return allTemplates.filter { template in
            template.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    /// 특정 운동이 포함된 템플릿 찾기
    func findTemplates(containingExercise exerciseId: PersistentIdentifier) async throws -> [WorkoutTemplate] {
        let allTemplates = try await getTemplates()
        
        return allTemplates.filter { template in
            template.exercises.contains { exercise in
                exercise.exercise?.id == exerciseId
            }
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 캐시 무효화
    private func invalidateCache() {
        cachedTemplates = []
        lastFetchTime = nil
    }
    
    /// 캐시 강제 갱신
    func refreshCache() async throws {
        invalidateCache()
        _ = try await getTemplates()
    }
} 