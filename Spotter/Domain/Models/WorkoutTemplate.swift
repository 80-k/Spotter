// WorkoutTemplate.swift
// 운동 계획 템플릿 모델 - 여러 운동을 포함하는 계획 템플릿
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

/// 운동 계획 템플릿 모델
@Model
final class WorkoutTemplate {
    // 기본 정보
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var exerciseItems: [ExerciseItem]? = [] // exercises → exerciseItems로 변경
    
    @Relationship(deleteRule: .cascade)
    var workoutSessions: [WorkoutSession]? = [] // sessions → workoutSessions로 변경
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.exerciseItems = []
        self.workoutSessions = []
    }
    
    /// 운동 추가
    func addExercise(_ exercise: ExerciseItem) {
        if exerciseItems == nil {
            exerciseItems = []
        }
        if !exerciseItems!.contains(where: { $0.id == exercise.id }) {
            exerciseItems!.append(exercise)
        }
    }
    
    /// 운동 제거
    func removeExercise(_ exercise: ExerciseItem) {
        exerciseItems?.removeAll(where: { $0.id == exercise.id })
    }
    
    /// 템플릿에 포함된 총 운동 수
    var exerciseCount: Int {
        return exerciseItems?.count ?? 0
    }
    
    /// 마지막으로 수행한 운동 세션
    var lastSession: WorkoutSession? {
        return workoutSessions?.sorted(by: { $0.startTime > $1.startTime }).first
    }
} 