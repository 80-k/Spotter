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
        // 템플릿과 연결된 세션 관계 정리
        if let sessions = template.workoutSessions {
            for session in sessions {
                // 세션과 연결된 세트들 삭제
                if let sets = session.workoutSets {
                    for set in sets {
                        modelContext.delete(set)
                    }
                }
                session.workoutTemplate = nil
                modelContext.delete(session)
            }
        }
        
        // 템플릿과 연결된 운동 관계 정리
        if let exercises = template.exerciseItems {
            for exercise in exercises {
                exercise.workoutTemplates?.removeAll(where: { $0.id == template.id })
            }
        }
        
        // 템플릿 삭제
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
    
    // 템플릿으로 운동 세션 시작 - 개선된 버전
    func startWorkout(with template: WorkoutTemplate) -> WorkoutSession {
        let session = WorkoutSession(workoutTemplate: template)
        
        // 세션 데이터베이스에 삽입
        modelContext.insert(session)
        
        // 템플릿의 각 운동에 대해 기본 세트 생성
        template.exerciseItems?.forEach { exercise in
            // 이전 세션에서 세트 값 가져오기
            let previousSets = getPreviousSetValues(for: exercise, in: template)
            
            if !previousSets.isEmpty {
                // 이전 세션의 세트 정보로 새 세트 생성
                for setValues in previousSets {
                    let newSet = session.createSet(for: exercise)
                    newSet.weight = setValues.weight
                    newSet.reps = setValues.reps
                }
            } else {
                // 기본 세트 3개 추가
                for _ in 0..<3 {
                    _ = session.createSet(for: exercise)
                }
            }
        }
        
        // 템플릿에 세션 추가
        if template.workoutSessions == nil {
            template.workoutSessions = []
        }
        template.workoutSessions?.append(session)
        
        do {
            try modelContext.save()
        } catch {
            print("운동 세션 시작 중 오류 발생: \(error)")
        }
        
        return session
    }
    
    // 이전 세션에서 특정 운동의 세트 정보 가져오기
    private func getPreviousSetValues(for exercise: ExerciseItem, in template: WorkoutTemplate) -> [(weight: Double, reps: Int)] {
        // 템플릿의 이전 세션 찾기
        let previousSessions = template.workoutSessions?.filter {
            $0.endTime != nil
        }.sorted(by: {
            ($0.endTime ?? Date()) > ($1.endTime ?? Date())
        }) ?? []
        
        // 최근 세션이 없으면 빈 배열 반환
        guard let latestSession = previousSessions.first else {
            return []
        }
        
        // 해당 운동의 세트 정보 가져오기
        let setValues = latestSession.workoutSets?.filter {
            $0.exerciseItem?.id == exercise.id && $0.weight > 0 && $0.reps > 0
        }.map {
            (weight: $0.weight, reps: $0.reps)
        } ?? []
        
        return setValues
    }
}
