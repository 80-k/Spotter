// WorkoutTemplate.swift
// 운동 계획 템플릿 모델 - 여러 운동을 포함하는 계획 템플릿
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    // 기본 정보
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var exercises: [ExerciseItem]? = []
    
    @Relationship(deleteRule: .cascade)
    var sessions: [WorkoutSession]? = []
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.exercises = []
        self.sessions = []
    }
    
    // 운동 추가 메서드
    func addExercise(_ exercise: ExerciseItem) {
        if exercises == nil {
            exercises = []
        }
        if !exercises!.contains(where: { $0.id == exercise.id }) {
            exercises!.append(exercise)
        }
    }
    
    // 운동 제거 메서드
    func removeExercise(_ exercise: ExerciseItem) {
        exercises?.removeAll(where: { $0.id == exercise.id })
    }
}
