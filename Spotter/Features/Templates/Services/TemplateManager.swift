// TemplateManager.swift
// 템플릿 관리 전담 클래스
// Created by woo on 4/19/25.

import Foundation
import SwiftData

/// 템플릿 관리 전담 클래스
///
/// 템플릿 관련 비즈니스 로직을 중앙화하고 단순화하기 위한 클래스입니다.
/// 복잡한 템플릿 관리 메서드를 작은 단위로 분리하여 단일 책임 원칙을 강화합니다.
final class TemplateManager {
    // MARK: - 속성
    
    /// 템플릿 저장소
    private let repository: TemplateRepository
    
    /// 비동기 작업 도우미
    private let operationHelper: AsyncOperationHelper
    
    /// 최근 사용 기간 (일)
    private let recentUsageDays: Int = 30
    
    // MARK: - 초기화
    
    /// 기본 초기화
    init(repository: TemplateRepository, operationHelper: AsyncOperationHelper = AsyncOperationHelper()) {
        self.repository = repository
        self.operationHelper = operationHelper
    }
    
    // MARK: - 템플릿 로드
    
    /// 모든 템플릿 로드
    func loadAllTemplates() async throws -> [WorkoutTemplate] {
        return try await repository.fetchAllTemplates()
    }
    
    /// 최근 사용한 템플릿 로드
    func loadRecentlyUsedTemplates() async throws -> [WorkoutTemplate] {
        let allTemplates = try await loadAllTemplates()
        
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -recentUsageDays, to: Date()) ?? Date()
        
        return allTemplates
            .filter { template in
                guard let lastUsed = template.lastUsedDate else { return false }
                return lastUsed > cutoffDate
            }
            .sorted { 
                ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast)
            }
    }
    
    /// 템플릿 이름으로 검색
    func searchTemplates(matching query: String) async throws -> [WorkoutTemplate] {
        guard !query.isEmpty else {
            return try await loadAllTemplates()
        }
        
        let allTemplates = try await loadAllTemplates()
        let lowercaseQuery = query.lowercased()
        
        return allTemplates.filter { template in
            template.name.lowercased().contains(lowercaseQuery)
        }
    }
    
    // MARK: - 템플릿 생성
    
    /// 새 템플릿 생성 (검증 포함)
    func createTemplate(name: String) async throws -> WorkoutTemplate {
        try validateTemplateName(name)
        return try await createTemplateInDatabase(name: name)
    }
    
    /// 템플릿 이름 검증
    private func validateTemplateName(_ name: String) throws {
        guard !name.isEmpty else {
            throw AppError.validationError("템플릿 이름은 비어있을 수 없습니다")
        }
        
        guard name.count <= 50 else {
            throw AppError.validationError("템플릿 이름은 50자를 초과할 수 없습니다")
        }
    }
    
    /// 실제 데이터베이스 템플릿 생성
    private func createTemplateInDatabase(name: String) async throws -> WorkoutTemplate {
        return try await repository.createTemplate(name: name)
    }
    
    // MARK: - 템플릿 수정
    
    /// 템플릿 수정
    func updateTemplate(_ template: WorkoutTemplate) async throws {
        try validateTemplateName(template.name)
        try await repository.updateTemplate(template)
    }
    
    /// 템플릿 마지막 사용 시간 업데이트
    func updateTemplateLastUsed(_ template: WorkoutTemplate) async throws {
        var updatedTemplate = template
        updatedTemplate.lastUsedDate = Date()
        try await repository.updateTemplate(updatedTemplate)
    }
    
    // MARK: - 템플릿 삭제
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) async throws {
        // 삭제 전 검증 (관련 워크아웃 세션 확인 등)
        try await validateTemplateForDeletion(template)
        
        // 실제 삭제 수행
        try await repository.deleteTemplate(template)
    }
    
    /// 삭제 전 템플릿 검증
    private func validateTemplateForDeletion(_ template: WorkoutTemplate) async throws {
        // 추가 검증 로직 필요시 여기에 구현
    }
    
    // MARK: - 워크아웃 세션
    
    /// 템플릿으로 워크아웃 세션 시작
    func startWorkoutWithTemplate(_ template: WorkoutTemplate) async throws -> WorkoutSession {
        // 템플릿 마지막 사용 시간 업데이트
        try await updateTemplateLastUsed(template)
        
        // 새 세션 생성
        let session = WorkoutSession(template: template)
        
        // 세션 저장 로직 (필요시)
        
        return session
    }
} 