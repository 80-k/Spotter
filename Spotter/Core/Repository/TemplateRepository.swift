// TemplateRepository.swift
// WorkoutTemplate 모델에 특화된 Repository 구현
// Created by woo on 4/1/25.

import Foundation
import SwiftData

class TemplateRepository: ModelRepository<WorkoutTemplate> {
    /// 최근 생성된 템플릿 순으로 가져오기
    func getRecentTemplates(limit: Int = 5) throws -> [WorkoutTemplate] {
        try getAll(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]).prefix(limit).map { $0 }
    }
    
    /// 특정 개수 이상의 운동을 포함하는 템플릿 가져오기
    func getTemplatesWithMinExerciseCount(_ count: Int) throws -> [WorkoutTemplate] {
        let allTemplates = try getAll()
        return allTemplates.filter { ($0.exercises?.count ?? 0) >= count }
    }
    
    /// 최근 사용된 템플릿 가져오기
    func getRecentlyUsedTemplates() throws -> [WorkoutTemplate] {
        let allTemplates = try getAll()
        
        return allTemplates
            .filter { $0.sessions?.isEmpty == false }
            .sorted {
                let lastUsed1 = $0.sessions?.max(by: { $0.startTime < $1.startTime })?.startTime ?? Date.distantPast
                let lastUsed2 = $1.sessions?.max(by: { $0.startTime < $1.startTime })?.startTime ?? Date.distantPast
                return lastUsed1 > lastUsed2
            }
    }
    
    /// 템플릿으로 운동 세션 시작 (SessionRepository 활용)
    func startWorkout(with template: WorkoutTemplate) throws -> WorkoutSession {
        // SessionRepository 인스턴스 생성
        let sessionRepo = SessionRepository(modelContext: modelContext)
        
        // SessionRepository를 통해 세션 생성 및 저장
        return try sessionRepo.createSession(with: template)
    }
}

// MARK: - RepositoryProtocol 구현

extension TemplateRepository: TemplateRepositoryProtocol {} 