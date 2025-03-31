// TemplateDetailViewModel.swift
// 운동 계획 템플릿 상세 화면 전용 뷰모델 - MVVM 패턴 적용
// Created by woo on 3/31/25.

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
class TemplateDetailViewModel {
    // MARK: - 프로퍼티
    
    // 모델 컨텍스트 
    private var modelContext: ModelContext
    
    // 현재 템플릿
    var template: WorkoutTemplate
    
    // 부모 뷰모델 (템플릿 목록 관리용)
    private var listViewModel: TemplateListViewModel
    
    // 네비게이션 상태
    var isExerciseSelectorPresented = false
    var isEditViewPresented = false
    var selectedExercise: ExerciseItem?
    
    // 초기화
    init(modelContext: ModelContext, template: WorkoutTemplate, listViewModel: TemplateListViewModel) {
        self.modelContext = modelContext
        self.template = template
        self.listViewModel = listViewModel
    }
    
    // MARK: - 템플릿 관리
    
    /// 특정 운동을 템플릿에서 제거
    func removeExerciseFromTemplate(_ exercise: ExerciseItem) {
        template.removeExercise(exercise)
        saveTemplate()
    }
    
    /// 템플릿에 운동 추가
    func addExerciseToTemplate(_ exercise: ExerciseItem) {
        template.addExercise(exercise)
        saveTemplate()
    }

    /// 템플릿 데이터 갱신
    func refreshTemplateData() {
        listViewModel.fetchTemplates()
        
        if let updatedTemplate = listViewModel.templates.first(where: { $0.id == template.id }) {
            template = updatedTemplate
        }
    }
    
    /// 템플릿 저장
    private func saveTemplate() {
        do {
            try modelContext.save()
            refreshTemplateData()
        } catch {
            print("템플릿 저장 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    /// 선택된 운동 목록으로 업데이트
    func updateExercises(with exercises: [ExerciseItem]) {
        // 기존 운동 목록을 새로운 목록으로 대체
        template.exercises = []
        
        // 새로운 운동들 추가
        for exercise in exercises {
            template.addExercise(exercise)
        }
        
        saveTemplate()
    }
    
    /// 운동 세션 시작
    func startWorkout() -> WorkoutSession? {
        return listViewModel.startWorkout(with: template)
    }
    
    // MARK: - 템플릿 분석
    
    /// 각 근육 그룹별 운동 개수
    var muscleGroupDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        
        template.exercises?.forEach { exercise in
            let group = exercise.muscleGroup
            distribution[group, default: 0] += 1
        }
        
        return distribution
    }
    
    /// 주요 근육 그룹 (가장 많은 운동이 있는 그룹)
    var primaryMuscleGroup: String? {
        muscleGroupDistribution.max { $0.value < $1.value }?.key
    }
    
    /// 이 템플릿을 사용한 세션 개수
    var sessionCount: Int {
        template.sessions?.count ?? 0
    }
    
    /// 최근 세션
    var recentSession: WorkoutSession? {
        template.sessions?
            .sorted { ($0.endTime ?? Date.distantPast) > ($1.endTime ?? Date.distantPast) }
            .first
    }
    
    // MARK: - 데이터 관리
    
    /// 모델 컨텍스트 업데이트 - 환경에서 제공된 컨텍스트 사용
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
    }
    
    /// 템플릿 데이터 새로고침
} 