// TemplateListViewModel.swift
// 운동 계획 템플릿 목록 관리 뷰모델 - Repository 패턴 적용
// Created by woo on 4/1/25.

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
class TemplateListViewModel {
    // MARK: - 프로퍼티
    
    // Repository
    private var templateRepository: TemplateRepository
    
    // 템플릿 목록
    var templates: [WorkoutTemplate] = []
    
    // 로딩 상태
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - 초기화
    
    init(repository: TemplateRepository) {
        self.templateRepository = repository
        fetchTemplates()
    }
    
    // 이전 버전과의 호환성을 위한 초기화
    init(modelContext: ModelContext) {
        self.templateRepository = TemplateRepository(modelContext: modelContext)
        fetchTemplates()
    }
    
    // MARK: - 템플릿 CRUD 작업
    
    /// 템플릿 목록 가져오기
    func fetchTemplates() {
        isLoading = true
        errorMessage = nil
        
        do {
            templates = try templateRepository.getAll(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            isLoading = false
        } catch {
            errorMessage = "템플릿 목록을 가져오는 중 오류가 발생했습니다"
            print("템플릿 목록을 가져오는 중 오류 발생: \(error)")
            isLoading = false
        }
    }
    
    /// 템플릿 추가
    func addTemplate(name: String) -> WorkoutTemplate? {
        guard !name.isEmpty else { return nil }
        
        let newTemplate = WorkoutTemplate(name: name)
        
        do {
            try templateRepository.save(newTemplate)
            fetchTemplates()
            return newTemplate
        } catch {
            print("템플릿 추가 중 오류 발생: \(error)")
            return nil
        }
    }
    
    /// 템플릿 업데이트
    func updateTemplate(_ template: WorkoutTemplate) {
        do {
            try templateRepository.update()
        } catch {
            print("템플릿 업데이트 중 오류 발생: \(error)")
        }
    }
    
    /// 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) {
        do {
            try templateRepository.delete(template)
            fetchTemplates()
        } catch {
            print("템플릿 삭제 중 오류 발생: \(error)")
        }
    }
    
    /// 여러 템플릿 삭제
    func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            if templates.indices.contains(index) {
                let template = templates[index]
                do {
                    try templateRepository.delete(template)
                } catch {
                    print("템플릿 삭제 중 오류 발생: \(error)")
                }
            }
        }
        
        fetchTemplates()
    }
    
    // MARK: - 운동 세션 관리
    
    /// 템플릿으로 운동 세션 시작
    func startWorkout(with template: WorkoutTemplate) -> WorkoutSession? {
        do {
            return try templateRepository.startWorkout(with: template)
        } catch {
            print("세션 생성 중 오류 발생: \(error)")
            return nil
        }
    }
    
    // MARK: - 편의 메서드
    
    /// 운동 개수로 템플릿 필터링
    func templates(withExerciseCountAtLeast count: Int) -> [WorkoutTemplate] {
        do {
            return try templateRepository.getTemplatesWithMinExerciseCount(count)
        } catch {
            print("템플릿 필터링 중 오류 발생: \(error)")
            return []
        }
    }
    
    /// 최근 사용된 템플릿 가져오기
    var recentlyUsedTemplates: [WorkoutTemplate] {
        do {
            return try templateRepository.getRecentlyUsedTemplates()
        } catch {
            print("최근 사용 템플릿 가져오기 중 오류 발생: \(error)")
            return []
        }
    }
} 