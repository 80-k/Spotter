// WorkoutTemplateListViewModel.swift
// 운동 계획 템플릿 목록 관리 뷰모델
//  Created by woo on 3/29/25.

import Foundation
import SwiftData
import SwiftUI

@Observable
class WorkoutTemplateListViewModel {
    // 데이터 모델 컨텍스트
    private var modelContext: ModelContext
    
    // 템플릿 목록
    var templates: [WorkoutTemplate] = []
    
    // 선택된 템플릿
    var selectedTemplate: WorkoutTemplate?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchTemplates()
    }
    
    // 템플릿 목록 가져오기
    func fetchTemplates() {
        do {
            let descriptor = FetchDescriptor<WorkoutTemplate>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            templates = try modelContext.fetch(descriptor)
        } catch {
            print("템플릿 목록을 가져오는 중 오류 발생: \(error)")
        }
    }
    
    // 템플릿 추가
    func addTemplate(name: String) {
        let newTemplate = WorkoutTemplate(name: name)
        modelContext.insert(newTemplate)
        
        do {
            try modelContext.save()
            fetchTemplates()
        } catch {
            print("템플릿 추가 중 오류 발생: \(error)")
        }
    }
    
    // 템플릿 업데이트
    func updateTemplate(_ template: WorkoutTemplate) {
        do {
            try modelContext.save()
        } catch {
            print("템플릿 업데이트 중 오류 발생: \(error)")
        }
    }
    
    // 템플릿 삭제
    func deleteTemplate(_ template: WorkoutTemplate) {
        modelContext.delete(template)
        
        do {
            try modelContext.save()
            fetchTemplates()
        } catch {
            print("템플릿 삭제 중 오류 발생: \(error)")
        }
    }
    
    // 템플릿에 운동 추가
    func addExerciseToTemplate(_ exercise: ExerciseItem, template: WorkoutTemplate) {
        template.addExercise(exercise)
        updateTemplate(template)
        fetchTemplates()
    }
    
    // 템플릿에서 운동 제거
    func removeExerciseFromTemplate(_ exercise: ExerciseItem, template: WorkoutTemplate) {
        template.removeExercise(exercise)
        updateTemplate(template)
        fetchTemplates()
    }
    
    // 템플릿으로 운동 세션 시작
    func startWorkout(with template: WorkoutTemplate) -> WorkoutSession {
        let session = WorkoutSession(template: template)
        
        // 템플릿의 각 운동에 대해 기본 세트 생성
        template.exercises?.forEach { exercise in
            // 각 운동에 대해 기본적으로 3세트 추가
            for _ in 0..<3 {
                session.addSet(for: exercise)
            }
        }
        
        modelContext.insert(session)
        
        // 템플릿에 세션 추가
        if template.sessions == nil {
            template.sessions = []
        }
        template.sessions?.append(session)
        
        do {
            try modelContext.save()
        } catch {
            print("운동 세션 시작 중 오류 발생: \(error)")
        }
        
        return session
    }
}
