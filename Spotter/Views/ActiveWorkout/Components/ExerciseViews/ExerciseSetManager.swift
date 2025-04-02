// ExerciseSetManager.swift
// 운동 세트 관리 프로토콜 및 확장
// Created by woo on 4/01/25.

import SwiftUI
import SwiftData

/// 운동 세트 관리 프로토콜
protocol ExerciseSetManagement {
    var viewModel: ActiveWorkoutViewModel { get }
    var exercise: ExerciseItem { get }
    
    /// 세트가 모두 완료되었는지 확인
    func areAllSetsCompleted(_ sets: [WorkoutSet]) -> Bool
    
    /// 일부 세트만 완료되었는지 확인
    func areSomeSetsCompleted(_ sets: [WorkoutSet]) -> Bool
    
    /// 세트 로드
    func loadSets() -> [WorkoutSet]
    
    /// 운동 상태 계산
    func calculateExerciseStatus(_ sets: [WorkoutSet]) -> ExerciseCompletionStatus
}

/// 운동 세트 관리 기본 구현
class ExerciseSetManagerImpl: ExerciseSetManagement {
    let viewModel: ActiveWorkoutViewModel
    let exercise: ExerciseItem
    
    init(viewModel: ActiveWorkoutViewModel, exercise: ExerciseItem) {
        self.viewModel = viewModel
        self.exercise = exercise
    }
    
    /// 세트가 모두 완료되었는지 확인
    func areAllSetsCompleted(_ sets: [WorkoutSet]) -> Bool {
        !sets.isEmpty && sets.allSatisfy { $0.isCompleted }
    }
    
    /// 일부 세트만 완료되었는지 확인
    func areSomeSetsCompleted(_ sets: [WorkoutSet]) -> Bool {
        sets.contains(where: { $0.isCompleted }) && !areAllSetsCompleted(sets)
    }
    
    /// 세트 로드
    func loadSets() -> [WorkoutSet] {
        let loadedSets = viewModel.getSetsForExercise(exercise)
        
        if loadedSets.isEmpty {
            // 세트가 없으면 하나 추가 후 다시 로드
            let newSet = viewModel.addSet(for: exercise)
            
            // 세트를 추가한 후 목록 다시 로드
            let updatedSets = viewModel.getSetsForExercise(exercise)
            
            if updatedSets.isEmpty {
                // 여전히 세트가 없다면 로컬 배열에 직접 추가
                return [newSet]
            } else {
                return updatedSets
            }
        } else {
            // 이미 세트가 있으면 그대로 사용
            return loadedSets
        }
    }
    
    /// 운동 상태 계산
    func calculateExerciseStatus(_ sets: [WorkoutSet]) -> ExerciseCompletionStatus {
        if areAllSetsCompleted(sets) {
            return .done
        } else if areSomeSetsCompleted(sets) {
            return .active
        } else {
            return .idle
        }
    }
} 