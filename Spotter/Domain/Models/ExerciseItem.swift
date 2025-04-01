// ExerciseItem.swift
// 운동 항목 모델 - 개별 운동의 정보를 저장
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

/// 운동 항목 모델
@Model
final class ExerciseItem {
    // 운동 기본 정보
    var name: String
    var muscleGroup: String
    var exerciseDescription: String // description -> exerciseDescription으로 다시 변경
    
    @Relationship(deleteRule: .cascade)
    var workoutTemplates: [WorkoutTemplate]? = []
    
    init(name: String, muscleGroup: String, exerciseDescription: String = "") {
        self.name = name
        self.muscleGroup = muscleGroup
        self.exerciseDescription = exerciseDescription
    }
    
    /// MuscleGroup 열거형 반환
    var muscleGroupEnum: MuscleGroup? {
        return MuscleGroup(rawValue: muscleGroup)
    }
} 